// Inputs e helpers
const usernameInput = document.getElementById('name');
const usernameHelper = document.getElementById('name-helper');
let usernameLabel = document.querySelector('label[for="Name"]');

let emailInput = document.getElementById('email');
let emailHelper = document.getElementById('email-helper');
let emailLabel = document.querySelector('label[for="email"]');

let phoneInput = document.getElementById('phone');
let phoneHelper = document.getElementById('phone-helper');
let phoneLabel = document.querySelector('label[for="phone"]');

let submitButton = document.getElementById('click_button');

// Função para exibir ou esconder o popup de campo obrigatório
function mostrarPopup(input, label) {
  input.addEventListener('focus', () => {
    label.classList.add('required-popup');
  });
  input.addEventListener('blur', () => {
    label.classList.remove('required-popup');
  });
}

// Função para validar cada campo
function validateField(input, regex, helper, errorMessage) {
  let value = input.value.trim();
  if (!regex.test(value)) {
    input.classList.add('error');
    input.classList.remove('correct');
    helper.innerText = errorMessage;
    helper.classList.add('visible');
    return false; // Campo inválido
  } else {
    input.classList.add('correct');
    input.classList.remove('error');
    helper.classList.remove('visible');
    return true; // Campo válido
  }
}

// Função de validação geral do formulário
function validateForm() {
  // Validações de cada campo
  let isUsernameValid = validateField(usernameInput, /^.{3,}$/, usernameHelper, "O nome deve ter pelo menos 3 caracteres");
  let isEmailValid = validateField(emailInput, /^[^\s@]+@[^\s@]+\.[^\s@]+$/, emailHelper, "O email deve ser nesse formato usuario@dominio.com");
  let isPhoneValid = validateField(phoneInput, /^\+?\d{1,4}[\s-]?\(?\d{2,3}\)?[\s-]?\d{4,5}[\s-]?\d{4}$/, phoneHelper, "O telefone deve ser nesse formato +55 11 91234-5678");

   // Verificar se todos os campos são válidos
  return isUsernameValid && isEmailValid && isPhoneValid;
}

// Evento de clique do botão de envio
submitButton.addEventListener('click', (e) => {
  e.preventDefault(); // Impede o envio automático do formulário

  // Revalida o formulário ao clicar no botão
  let isFormValid = validateForm();

  // Checa se o formulário está válido
  if (isFormValid) {
    alert("Formulário enviado com sucesso!");
    // Enviar o formulário aqui se necessário
  } else {
    alert("Complete os campos faltantes!");
  }
});

// Exibir popup ao focar nos campos
mostrarPopup(usernameInput, usernameLabel);
mostrarPopup(emailInput, emailLabel);
mostrarPopup(phoneInput, phoneLabel);

// Validar o formulário ao mudar os campos
usernameInput.addEventListener('input', validateForm);
emailInput.addEventListener('input', validateForm);
phoneInput.addEventListener('input', validateForm);
