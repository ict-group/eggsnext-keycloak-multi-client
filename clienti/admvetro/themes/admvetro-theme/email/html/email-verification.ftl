<#ftl output_format="HTML">
<#assign realm = realmName!msg("companyName")>
<#assign actionLink = link!"">
<#assign expirationText = "">
<#attempt>
  <#assign expirationText = linkExpirationFormatter(linkExpiration)>
<#recover>
  <#assign expirationText = "">
</#attempt>
<#assign logoUrl = "">
<#attempt>
  <#assign logoUrl = url.resourcesUrl + "/img/logo-admvetro.png">
<#recover>
  <#assign logoUrl = msg("emailLogoUrl")!"">
</#attempt>
<!doctype html>
<html lang="it">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="x-ua-compatible" content="ie=edge">
  <title>${msg("verifyTitle")}</title>
</head>
<body style="margin:0;padding:0;background:#c5df57;font-family:Arial,Helvetica,sans-serif;color:#202428;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#c5df57;margin:0;padding:34px 12px;">
    <tr>
      <td align="center">
        <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:620px;background:#ffffff;border-radius:18px;overflow:hidden;border:1px solid rgba(32,36,34,0.10);box-shadow:0 14px 32px rgba(0,0,0,0.16);">
          <tr>
            <td style="background:#272a29;padding:30px 30px 24px;text-align:center;">
              <img src="${logoUrl}" width="230" alt="${msg('companyName')}" style="display:inline-block;max-width:230px;width:100%;height:auto;border:0;outline:none;text-decoration:none;">
            </td>
          </tr>
          <tr>
            <td style="padding:34px 36px 24px 36px;background:#ffffff;">
              <h1 style="margin:0 0 14px 0;font-size:25px;line-height:1.25;color:#272a29;font-weight:800;">${msg("verifyTitle")}</h1>
              <p style="margin:0 0 14px 0;font-size:16px;line-height:1.6;color:#3d4540;">Ciao,</p>
              <p style="margin:0 0 14px 0;font-size:16px;line-height:1.6;color:#3d4540;">
                ${msg("verifyIntro")} <strong style="color:#272a29;">${realm}</strong>.
              </p>
              <p style="margin:0 0 22px 0;font-size:16px;line-height:1.6;color:#3d4540;">${msg("verifyHelp")}</p>

              <table role="presentation" cellpadding="0" cellspacing="0" style="margin:28px 0 26px 0;">
                <tr>
                  <td align="center" bgcolor="#a6d51c" style="border-radius:999px;">
                    <a href="${actionLink}" style="display:inline-block;padding:14px 28px;font-size:15px;font-weight:800;line-height:1.2;color:#17345a;text-decoration:none;border-radius:999px;background:#a6d51c;text-transform:uppercase;letter-spacing:0.04em;">${msg("verifyButton")}</a>
                  </td>
                </tr>
              </table>
              <p style="margin:0 0 12px 0;font-size:14px;line-height:1.6;color:#5d665f;">
                ${msg("linkExpirationText")} <strong>${expirationText}</strong>.
              </p>
              <p style="margin:0 0 18px 0;font-size:14px;line-height:1.6;color:#5d665f;">${msg("ignoreText")}</p>
              <div style="margin:24px 0 0 0;padding:16px;background:#f6f9ea;border-radius:12px;border:1px solid #dbe8a4;">
                <p style="margin:0 0 8px 0;font-size:13px;line-height:1.5;color:#677060;">${msg("fallbackText")}</p>
                <a href="${actionLink}" style="font-size:13px;line-height:1.5;color:#7aa313;word-break:break-all;text-decoration:none;font-weight:700;">${actionLink}</a>
              </div>
            </td>
          </tr>
          <tr>
            <td style="padding:22px 36px 30px 36px;background:#f7f8f3;border-top:1px solid #edf2d4;">
              <p style="margin:0 0 8px 0;font-size:13px;line-height:1.6;color:#6b736c;">${msg("footerText")}</p>
              <p style="margin:0;font-size:13px;line-height:1.6;color:#6b736c;">
                <strong style="color:#272a29;">${msg("companyName")}</strong><br>
                ${msg("companyAddress")}<br>
                ${msg("companyPhone")} · <a href="mailto:${msg('companyEmail')}" style="color:#7aa313;text-decoration:none;font-weight:700;">${msg("companyEmail")}</a><br>
                <a href="${msg('companyWebsite')}" style="color:#7aa313;text-decoration:none;font-weight:700;">${msg("companyWebsite")}</a>
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
