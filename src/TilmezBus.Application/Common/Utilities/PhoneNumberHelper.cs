namespace TilmezBus.Application.Common.Utilities;

/// <summary>
/// Canonicalises Jordanian mobile numbers so DB writes and lookups are
/// consistent regardless of which format the operator typed. The 9-digit
/// local part is always "7XXXXXXXX" — first digit is 7 (mobile range) and
/// the second digit is 7, 8, or 9 (077 / 078 / 079 carrier prefixes).
/// Canonical form is the international "+9627XXXXXXXX". Accepted inputs:
///   07XXXXXXXX     (legacy local, 10 digits, prefix 077/078/079)
///   7XXXXXXXX      (9 digits, no leading 0)
///   +9627XXXXXXXX  (already canonical — passes through)
///   9627XXXXXXXX   (canonical without +)
///   009627XXXXXXXX (E.164 with international prefix)
/// Punctuation, spaces, and dashes are stripped before checking.
/// </summary>
public static class PhoneNumberHelper
{
    private const string CountryDial = "+962";

    /// <summary>
    /// Returns the canonical "+9627XXXXXXXX" form if the input represents a
    /// valid Jordanian mobile, otherwise returns the raw input back unchanged.
    /// The caller decides what to do with non-matching values (typically the
    /// validators reject them downstream).
    /// </summary>
    public static string Normalize(string? raw)
    {
        if (string.IsNullOrWhiteSpace(raw)) return string.Empty;

        // Strip everything except digits and a single leading '+'.
        var sb = new System.Text.StringBuilder(raw.Length);
        bool seenPlus = false;
        foreach (var ch in raw)
        {
            if (ch == '+' && !seenPlus) { sb.Append('+'); seenPlus = true; continue; }
            if (char.IsDigit(ch)) sb.Append(ch);
        }
        var s = sb.ToString();

        // 009627XXXXXXXX → +9627XXXXXXXX
        if (s.StartsWith("00962")) s = "+" + s[2..];
        // 9627XXXXXXXX → +9627XXXXXXXX
        else if (s.StartsWith("962") && !s.StartsWith("+962")) s = "+" + s;
        // 07XXXXXXXX → +9627XXXXXXXX (legacy local form, prefix 077/078/079)
        else if (s.Length == 10 && s.StartsWith("07") && IsValidSecondDigit(s[2])) s = CountryDial + s[1..];
        // 7XXXXXXXX  → +9627XXXXXXXX (9 digits, prefix 77/78/79)
        else if (s.Length == 9 && s.StartsWith("7") && IsValidSecondDigit(s[1])) s = CountryDial + s;

        return s;
    }

    /// <summary>Second digit of the local part must be 7, 8, or 9 (the
    /// 077 / 078 / 079 carrier prefixes for Jordan mobiles).</summary>
    private static bool IsValidSecondDigit(char c) => c is '7' or '8' or '9';

    /// <summary>
    /// Given a canonical "+9627XXXXXXXX", returns the legacy local "07XXXXXXXX"
    /// form so callers can match against either format during the transition.
    /// Returns null when <paramref name="canonical"/> isn't in canonical form.
    /// </summary>
    public static string? LegacyLocalForm(string canonical)
    {
        if (string.IsNullOrEmpty(canonical)) return null;
        if (!canonical.StartsWith(CountryDial)) return null;
        var rest = canonical[CountryDial.Length..];
        return rest.Length == 9 ? "0" + rest : null;
    }
}
