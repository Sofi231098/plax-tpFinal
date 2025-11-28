// ***********************************************
// URL del backend por URL PUBLICA DE AWS EC2
// ***********************************************
window.API_URL = "http://18.116.53.192:8080" || "http://localhost:8080";

// ***********************************************
// GOOGLE ANALYTICS (GA4) + TRACKING DE RUTAS SPA
// ***********************************************
(function () {
  const GA_MEASUREMENT_ID = 'G-84QYLJR782';

  // dataLayer y gtag global
  window.dataLayer = window.dataLayer || [];
  function gtag() { window.dataLayer.push(arguments); }
  window.gtag = gtag;

  // Cargar script externo de GA
  const gaScript = document.createElement('script');
  gaScript.async = true;
  gaScript.src = `https://www.googletagmanager.com/gtag/js?id=${GA_MEASUREMENT_ID}`;
  document.head.appendChild(gaScript);

  // ---- función para enviar page_view de la ruta actual ----
  function sendPageView() {
    const path = window.location.pathname + window.location.search;
    console.log('[GA] page_view', path);
    gtag('config', GA_MEASUREMENT_ID, {
      page_path: path
    });
  }

  // Inicializar GA y mandar el primer page_view
  gtag('js', new Date());
  sendPageView();

  // ---- Hook a las navegaciones de la SPA (React Router) ----
  const originalPushState = history.pushState;
  const originalReplaceState = history.replaceState;

  history.pushState = function (...args) {
    originalPushState.apply(this, args);
    sendPageView();
  };

  history.replaceState = function (...args) {
    originalReplaceState.apply(this, args);
    sendPageView();
  };

  window.addEventListener('popstate', sendPageView);
})();