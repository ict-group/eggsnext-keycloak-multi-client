<#ftl output_format="HTML">
<#assign realm = realmName!msg("companyName")>
<#assign resetLink = link!"">
<#assign expirationText = "">
<#attempt>
  <#assign expirationText = linkExpirationFormatter(linkExpiration)>
<#recover>
  <#assign expirationText = "">
</#attempt>
<#assign logoUrl = "">
<#attempt>
  <#assign logoUrl = url.resourcesUrl + "/img/virgilio_logo.png">
<#recover>
  <#assign logoUrl = msg("emailLogoUrl")!"">
</#attempt>
<!doctype html>
<html lang="it">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="x-ua-compatible" content="ie=edge">
  <title>${msg("resetTitle")}</title>
</head>
<body style="margin:0;padding:0;background:#eef0fb;font-family:Arial,Helvetica,sans-serif;color:#202428;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#eef0fb;margin:0;padding:34px 12px;">
    <tr>
      <td align="center">
        <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:620px;background:#ffffff;border-radius:18px;overflow:hidden;border:1px solid rgba(3,12,119,0.10);box-shadow:0 14px 32px rgba(3,12,119,0.16);">
          <tr>
            <td style="background:#ffffff;padding:30px 30px 24px;text-align:center;border-bottom:4px solid #212dc1;">
              <img src="${logoUrl}" width="230" alt="${msg('companyName')}" style="display:inline-block;max-width:230px;width:100%;height:auto;border:0;outline:none;text-decoration:none;">
            </td>
          </tr>
          <tr>
            <td style="padding:34px 36px 24px 36px;background:#ffffff;">
              <h1 style="margin:0 0 14px 0;font-size:25px;line-height:1.25;color:#212dc1;font-weight:800;">${msg("resetTitle")}</h1>
              <p style="margin:0 0 14px 0;font-size:16px;line-height:1.6;color:#3d4046;">Ciao,</p>
              <p style="margin:0 0 14px 0;font-size:16px;line-height:1.6;color:#3d4046;">
                ${msg("resetIntro")} <strong style="color:#212dc1;">${realm}</strong>.
              </p>
              <p style="margin:0 0 22px 0;font-size:16px;line-height:1.6;color:#3d4046;">${msg("resetHelp")}</p>

              <table role="presentation" cellpadding="0" cellspacing="0" style="margin:28px 0 26px 0;">
                <tr>
                  <td align="center" bgcolor="#212dc1" style="border-radius:999px;">
                    <a href="${resetLink}" style="display:inline-block;padding:14px 28px;font-size:15px;font-weight:800;line-height:1.2;color:#ffffff;text-decoration:none;border-radius:999px;background:#212dc1;text-transform:uppercase;letter-spacing:0.04em;">${msg("resetButton")}</a>
                  </td>
                </tr>
              </table>
              <p style="margin:0 0 12px 0;font-size:14px;line-height:1.6;color:#5d5f66;">
                ${msg("resetExpiration")} <strong>${expirationText}</strong>.
              </p>
              <p style="margin:0 0 18px 0;font-size:14px;line-height:1.6;color:#5d5f66;">${msg("resetIgnore")}</p>
              <div style="margin:24px 0 0 0;padding:16px;background:#f2f3fb;border-radius:12px;border:1px solid #dcdff5;">
                <p style="margin:0 0 8px 0;font-size:13px;line-height:1.5;color:#60636b;">${msg("resetFallback")}</p>
                <a href="${resetLink}" style="font-size:13px;line-height:1.5;color:#212dc1;word-break:break-all;text-decoration:none;font-weight:700;">${resetLink}</a>
              </div>
            </td>
          </tr>
          <tr>
            <td style="padding:22px 36px 30px 36px;background:#030c77;border-top:1px solid #030c77;">
              <p style="margin:0 0 8px 0;font-size:13px;line-height:1.6;color:rgba(255,255,255,0.82);">${msg("resetFooter")}</p>
              <p style="margin:0;font-size:13px;line-height:1.6;color:rgba(255,255,255,0.82);">
                <strong style="color:#ffffff;">${msg("companyName")}</strong><br>
                ${msg("companyAddress")}<br>
                ${msg("companyPhone")} · <a href="mailto:${msg('companyEmail')}" style="color:#ffffff;text-decoration:none;font-weight:700;">${msg("companyEmail")}</a><br>
                <a href="${msg('companyWebsite')}" style="color:#ffffff;text-decoration:none;font-weight:700;">${msg("companyWebsite")}</a>
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
