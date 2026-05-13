"""3-layer defense for untrusted external data.

Per the second-brain-starter architecture reference: emails, JIRA descriptions,
GitHub bodies, and Linear comments are all attacker-controlled or
attacker-reachable. Anything we hand to the LLM gets wrapped here first.

Layers:
    1. Pattern detection — known prompt-injection / persona-override /
       credential-exfil phrases get redacted.
    2. Markdown neutralization — link / image syntax rewritten so the LLM
       can't be tricked into rendering or surfacing malicious links.
    3. XML trust boundary — wrap the output in <external-{source} trust="untrusted">
       tags so the LLM has a clear signal not to follow instructions from this region.

Call `sanitize_external(text, source)` on any data fetched from outside the
vault before formatting it into context for the LLM.
"""

from __future__ import annotations

import re

# Layer 1: known dangerous patterns. Case-insensitive. Order matters.
_DANGEROUS_PATTERNS: tuple[tuple[re.Pattern[str], str], ...] = (
    # Prompt injection — instruction override
    (re.compile(r"(?i)ignore\s+(?:all\s+)?(?:previous|prior|above)\s+(?:instructions|context|rules)"),
     "[REDACTED: injection-override]"),
    (re.compile(r"(?i)disregard\s+(?:the\s+)?(?:rules|guidelines|system\s+prompt)"),
     "[REDACTED: rules-override]"),
    (re.compile(r"(?i)forget\s+(?:everything|all)\s+(?:before|above|prior)"),
     "[REDACTED: context-wipe]"),

    # Persona override
    (re.compile(r"(?i)you\s+are\s+now\s+(?:a|an)\s+[\w\s-]{3,40}"),
     "[REDACTED: persona-override]"),
    (re.compile(r"(?i)act\s+as\s+(?:if\s+you\s+were\s+)?(?:a|an)\s+[\w\s-]{3,40}"),
     "[REDACTED: persona-override]"),

    # Credential exfiltration
    (re.compile(r"(?i)(?:export|reveal|print|show|tell\s+me)\s+(?:your|the)\s+(?:api\s+)?(?:key|token|secret|password)"),
     "[REDACTED: credential-exfil]"),
    (re.compile(r"(?i)send\s+(?:your|the)\s+(?:credentials|tokens|api\s+keys?)\s+to"),
     "[REDACTED: credential-exfil]"),
)


def _layer1_pattern_detection(text: str) -> str:
    out = text
    for pattern, replacement in _DANGEROUS_PATTERNS:
        out = pattern.sub(replacement, out)
    return out


def _layer2_markdown_neutralize(text: str) -> str:
    """Defang URLs and images so the LLM can't accidentally render
    malicious destinations.

    Markdown link syntax `[label](url)` → `[label](sanitized-link)`
    Markdown image syntax `![alt](url)` → `[image: alt]`
    Bare URLs are preserved (LLM can see them but they're tagged as untrusted
    via the XML boundary in layer 3).
    """
    # Images first (more specific pattern)
    out = re.sub(r"!\[([^\]]*)\]\([^)]+\)", r"[image: \1]", text)
    # Then links
    out = re.sub(r"(?<!!)\[([^\]]+)\]\(([^)]+)\)", r"[\1](sanitized-link)", out)
    return out


def _layer3_trust_boundary(text: str, source: str) -> str:
    """Wrap untrusted content with an XML tag the LLM can recognize."""
    safe_source = re.sub(r"[^a-z0-9-]", "", source.lower()) or "untrusted"
    return (
        f'<external-{safe_source} trust="untrusted">\n'
        f"{text.rstrip()}\n"
        f"</external-{safe_source}>"
    )


def sanitize_external(text: str, source: str) -> str:
    """Apply all three layers in order. Empty input returns empty string."""
    if not text:
        return ""
    out = _layer1_pattern_detection(text)
    out = _layer2_markdown_neutralize(out)
    out = _layer3_trust_boundary(out, source)
    return out
