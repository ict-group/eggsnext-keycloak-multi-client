<#ftl output_format="HTML">
<#--
  Keycloak 24 - Email HTML: password reset
  CPS Facility Management
  Variabili Keycloak usate: link, linkExpiration, realmName, linkExpirationFormatter(...)
-->
<#assign realm = realmName!msg("companyName")>
<#assign resetLink = link!"">
<#assign expirationText = "">
<#attempt>
  <#assign expirationText = linkExpirationFormatter(linkExpiration)>
  <#recover>
    <#assign expirationText = "">
</#attempt>
<!doctype html>
<html lang="it">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="x-ua-compatible" content="ie=edge">
  <title>${msg("resetTitle")}</title>
</head>
<body style="margin:0;padding:0;background:#f4f6f8;font-family:Arial,Helvetica,sans-serif;color:#202428;">
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#f4f6f8;margin:0;padding:32px 12px;">
  <tr>
    <td align="center">
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:620px;background:#ffffff;border-radius:18px;overflow:hidden;border:1px solid #e4e7eb;box-shadow:0 10px 28px rgba(0,0,0,0.08);">

        <!-- HEADER ROSSO CPS -->
        <tr>
          <td style="background:#E30613;padding:28px 30px;text-align:center;">
            <img src="${msg('emailLogoUrl')}" width="180" alt="${msg('companyName')}" style="display:inline-block;max-width:180px;width:100%;height:auto;border:0;outline:none;text-decoration:none;">
          </td>
        </tr>

        <!-- STRISCIA DECORATIVA -->
        <tr>
          <td style="background:#A00010;height:4px;font-size:0;line-height:0;">&nbsp;</td>
        </tr>

        <!-- CORPO EMAIL -->
        <tr>
          <td style="padding:34px 34px 22px 34px;">
            <h1 style="margin:0 0 14px 0;font-size:25px;line-height:1.25;color:#15171a;font-weight:700;">${msg("resetTitle")}</h1>
            <p style="margin:0 0 14px 0;font-size:16px;line-height:1.6;color:#3b4046;">Ciao,</p>
            <p style="margin:0 0 14px 0;font-size:16px;line-height:1.6;color:#3b4046;">
              ${msg("resetIntro")} <strong style="color:#15171a;">${realm}</strong>.
            </p>
            <p style="margin:0 0 22px 0;font-size:16px;line-height:1.6;color:#3b4046;">${msg("resetHelp")}</p>

            <!-- BOTTONE -->
            <table role="presentation" cellpadding="0" cellspacing="0" style="margin:28px 0 26px 0;">
              <tr>
                <td align="center" bgcolor="#E30613" style="border-radius:999px;">
                  <a href="${resetLink}" style="display:inline-block;padding:14px 36px;font-size:16px;font-weight:700;line-height:1.2;color:#ffffff;text-decoration:none;border-radius:999px;background:#E30613;">${msg("resetButton")}</a>
                </td>
              </tr>
            </table>

            <p style="margin:0 0 12px 0;font-size:14px;line-height:1.6;color:#555d66;">
              ${msg("resetExpiration")} <strong>${expirationText}</strong>.
            </p>
            <p style="margin:0 0 18px 0;font-size:14px;line-height:1.6;color:#555d66;">${msg("resetIgnore")}</p>

            <!-- LINK FALLBACK -->
            <div style="margin:24px 0 0 0;padding:16px;background:#f7f8fa;border-radius:12px;border:1px solid #e8eaee;">
              <p style="margin:0 0 8px 0;font-size:13px;line-height:1.5;color:#6b7280;">${msg("resetFallback")}</p>
              <a href="${resetLink}" style="font-size:13px;line-height:1.5;color:#E30613;word-break:break-all;text-decoration:none;">${resetLink}</a>
            </div>
          </td>
        </tr>

        <!-- FOOTER -->
        <tr>
          <td style="padding:22px 34px 30px 34px;background:#fafafa;border-top:1px solid #edf0f2;">
            <p style="margin:0 0 8px 0;font-size:13px;line-height:1.6;color:#6b7280;">${msg("resetFooter")}</p>
            <p style="margin:0;font-size:13px;line-height:1.6;color:#6b7280;">
              <strong style="color:#15171a;">${msg("companyName")}</strong><br>
              ${msg("companyAddress")}<br>
              ${msg("companyPhone")} · <a href="mailto:${msg('companyEmail')}" style="color:#E30613;text-decoration:none;">${msg("companyEmail")}</a><br>
              <a href="${msg('companyWebsite')}" style="color:#E30613;text-decoration:none;">${msg("companyWebsite")}</a>
            </p>
          </td>
        </tr>

      </table>
    </td>
  </tr>
</table>
</body>
</html>