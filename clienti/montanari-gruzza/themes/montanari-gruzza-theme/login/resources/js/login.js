// Text inputs also match :focus-visible after a pointer click.
document.documentElement.classList.add("montanari-gruzza-pointer-focus");
document.addEventListener("pointerdown", () => {
    document.documentElement.classList.add("montanari-gruzza-pointer-focus");
}, true);
document.addEventListener("keydown", (event) => {
    if (event.key === "Tab") {
        document.documentElement.classList.remove("montanari-gruzza-pointer-focus");
    }
}, true);

const toggle = document.querySelector(".montanari-gruzza-password-toggle");
const password = document.getElementById("password");

if (toggle && password) {
    toggle.hidden = false;
    toggle.addEventListener("click", () => {
        const visible = password.type === "password";
        password.type = visible ? "text" : "password";
        toggle.setAttribute("aria-pressed", String(visible));
        toggle.setAttribute("aria-label", visible ? toggle.dataset.labelHide : toggle.dataset.labelShow);
    });
}

const form = document.getElementById("kc-form-login");
if (form) {
    form.addEventListener("submit", () => {
        document.getElementById("kc-login").disabled = true;
    });
}
