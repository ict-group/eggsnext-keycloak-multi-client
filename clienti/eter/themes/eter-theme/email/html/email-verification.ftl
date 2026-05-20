<#-- PROGES - email verification -->
<!DOCTYPE html>
<html lang="it">
<head><meta charset="UTF-8" /><meta name="viewport" content="width=device-width, initial-scale=1.0" /><title>${msg("verifyTitle")}</title></head>
<body style="margin:0;padding:0;background:#f3f6fa;font-family:Arial,Helvetica,sans-serif;color:#162033;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#f3f6fa;padding:32px 12px;"><tr><td align="center">
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:640px;background:#ffffff;border-radius:14px;overflow:hidden;box-shadow:0 18px 44px rgba(0,0,0,.08);">
      <tr><td style="background:#ffffff;padding:34px 32px 28px;text-align:center;border-top:6px solid #f4a6b5;"><img src="${url.resourcesUrl}/img/logo.png" alt="${msg("companyName")}" style="display:inline-block;max-width:250px;width:70%;height:auto;border:0;" /></td></tr>
      <tr><td style="padding:28px 36px 34px;">
        <h1 style="margin:0 0 18px;font-size:24px;line-height:1.25;color:#0075a9;font-weight:800;">${msg("verifyTitle")}</h1>
        <p style="margin:0 0 14px;font-size:15px;line-height:1.6;color:#162033;">Ciao<#if user?? && user.firstName??> ${user.firstName}</#if>,</p>
        <p style="margin:0 0 14px;font-size:15px;line-height:1.6;color:#162033;">${msg("verifyIntro")}</p>
        <p style="margin:0 0 24px;font-size:15px;line-height:1.6;color:#162033;">${msg("verifyHelp")}</p>
        <table role="presentation" cellpadding="0" cellspacing="0" style="margin:0 0 24px;"><tr><td bgcolor="#f4a6b5" style="border-radius:8px;"><a href="${link}" style="display:inline-block;padding:13px 24px;font-size:13px;font-weight:800;color:#162033;text-decoration:none;text-transform:uppercase;letter-spacing:.04em;border-radius:8px;background:#f4a6b5;">${msg("verifyButton")}</a></td></tr></table>
        <p style="margin:0 0 12px;font-size:13px;line-height:1.6;color:#667085;">${msg("verifyExpiration")} <strong>${linkExpiration}</strong> ${msg("minutes")}.</p>
        <p style="margin:0 0 18px;font-size:13px;line-height:1.6;color:#667085;">${msg("verifyIgnore")}</p>
        <div style="margin:22px 0 0;padding:16px;background:#f3f6fa;border-radius:10px;border-left:4px solid #0075a9;"><p style="margin:0 0 8px;font-size:12px;color:#667085;">${msg("verifyFallback")}</p><a href="${link}" style="word-break:break-all;color:#0075a9;font-size:12px;line-height:1.5;text-decoration:none;">${link}</a></div>
      </td></tr>
      <tr><td style="padding:18px 36px;background:#162033;color:#ffffff;text-align:center;"><p style="margin:0 0 6px;font-size:13px;font-weight:700;">${msg("companyName")}</p><p style="margin:0;font-size:12px;line-height:1.5;color:rgba(255,255,255,.78);">${msg("resetFooter")}</p></td></tr>
    </table>
  </td></tr></table>
</body>
</html>
