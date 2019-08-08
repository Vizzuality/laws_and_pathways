const loadGravatar = () => {
  const avatarElement = document.querySelector('#utility_nav');
  avatarElement.style = `
    background: url(${window.LawsAndPathways.user.gravatarUrl}) no-repeat;
    background-size: contain;
    border-radius: 50%;
  `;
};

document.addEventListener("DOMContentLoaded", loadGravatar);
document.addEventListener("turbolinks:load", loadGravatar);
