${msg("resetTitle")}

Ciao<#if user?? && user.firstName??> ${user.firstName}</#if>,

${msg("resetIntro")} ${realmName!"Keycloak"}.
${msg("resetHelp")}

${link}

${msg("resetExpiration")} ${linkExpiration} ${msg("minutes")}.
${msg("resetIgnore")}

${msg("companyName")}
${msg("resetFooter")}
