<#import "template.ftl" as layout>
<!DOCTYPE html>
<html class="${properties.kcHtmlClass!}" lang="${locale.currentLanguageTag!'it'}">
<head>
    <meta charset="utf-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="robots" content="noindex, nofollow">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>${msg("loginTitle",(realm.displayName!''))}</title>

    <link rel="icon" href="${url.resourcesPath}/img/favicon.ico" />

    <#if properties.stylesCommon?has_content>
        <#list properties.stylesCommon?split(' ') as style>
            <link href="${url.resourcesCommonPath}/${style}" rel="stylesheet" />
        </#list>
    </#if>

    <#if properties.styles?has_content>
        <#list properties.styles?split(' ') as style>
            <link href="${url.resourcesPath}/${style}" rel="stylesheet" />
        </#list>
    <#else>
        <link href="${url.resourcesPath}/css/style.css" rel="stylesheet" />
    </#if>
</head>

<body class="eter-body">

<div class="eter-page">

    <main class="eter-shell">

        <!-- CARD LOGIN SINISTRA -->
        <section class="eter-login-card">

            <div class="eter-logo">
                <img src="${url.resourcesPath}/img/logo.png" alt="ETER">
            </div>

            <#if message?has_content && (message.type != 'warning' || !isAppInitiatedAction??)>
                <div class="eter-alert eter-alert-${message.type}">
                    <span>${kcSanitize(message.summary)?no_esc}</span>
                </div>
            </#if>

            <form id="kc-form-login"
                  class="eter-login-form"
                  action="${url.loginAction}"
                  method="post">

                <div class="eter-field">
                    <label for="username">
                        <#if !realm.loginWithEmailAllowed>
                            ${msg("username")}
                        <#elseif !realm.registrationEmailAsUsername>
                            ${msg("usernameOrEmail")}
                        <#else>
                            ${msg("email")}
                        </#if>
                    </label>

                    <input tabindex="1"
                           id="username"
                           name="username"
                           value="${(login.username!'')}"
                           type="text"
                           autofocus
                           autocomplete="username"
                           aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>" />
                </div>

                <div class="eter-field">
                    <label for="password">${msg("password")}</label>

                    <input tabindex="2"
                           id="password"
                           name="password"
                           type="password"
                           autocomplete="current-password"
                           aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>" />
                </div>

                <#if messagesPerField.existsError('username','password')>
                    <div class="eter-input-error">
                        ${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}
                    </div>
                </#if>

                <#if realm.rememberMe && !usernameEditDisabled??>
                    <div class="eter-remember">
                        <label>
                            <#if login.rememberMe??>
                                <input tabindex="3" id="rememberMe" name="rememberMe" type="checkbox" checked>
                            <#else>
                                <input tabindex="3" id="rememberMe" name="rememberMe" type="checkbox">
                            </#if>
                            <span>${msg("rememberMe")}</span>
                        </label>
                    </div>
                </#if>

                <#if credentialId??>
                    <input type="hidden" id="id-hidden-input" name="credentialId" value="${credentialId}" />
                </#if>

                <button tabindex="4"
                        class="eter-login-button"
                        name="login"
                        id="kc-login"
                        type="submit">
                    LOG IN
                </button>

                <a class="eter-site-button"
                   href="https://www.eter.it"
                   target="_blank"
                   rel="noopener noreferrer">
                    TORNA SUL SITO
                </a>

                <#if realm.resetPasswordAllowed>
                    <div class="eter-forgot">
                        <a tabindex="5" href="${url.loginResetCredentialsUrl}">
                            ${msg("doForgotPassword")}
                        </a>
                    </div>
                </#if>

            </form>

        </section>

        <!-- CARD PROMO DESTRA -->
        <aside class="eter-promo-card">

            <div class="eter-promo-image"></div>

            <div class="eter-promo-content">
                <h2>Non sei ancora un nostro cliente ?</h2>

                <p>
                    Accedi a un catalogo di oltre 1500 prodotti di sicurezza e
                    approfitta del nostro supporto pre-vendita e post-vendita
                </p>

                <a class="eter-register-button"
                   href="https://www.eter.it/registrazione"
                   target="_blank"
                   rel="noopener noreferrer">
                    REGISTRAZIONE NUOVO CLIENTE
                </a>
            </div>

        </aside>

    </main>

</div>

</body>
</html>