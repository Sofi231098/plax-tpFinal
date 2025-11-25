import axios from 'axios';
const API_URL = window.API_URL;

const api = axios.create({
    baseURL: `${API_URL}/api`,
});


api.interceptors.response.use(
    response => response,
    error => {
        const requestUrl = error.config.url;
        if (error.response.status === 401 && !requestUrl.includes('auth/login')) {
            alert('Su sesión ha expirado. Por favor, inicie sesión nuevamente.');
            localStorage.removeItem('token');
            localStorage.removeItem('user');
            window.location = '/iniciar-sesion';
        }
        return Promise.reject(error);
    }
)

export default api;
