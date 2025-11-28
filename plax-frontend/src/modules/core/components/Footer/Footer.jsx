import { useContext } from 'react';
import { Link } from 'react-router-dom';
import Isologo from '../../../../assets/images/Isologotipo.png';
import { NotificationContext } from '../../context/notificationContext';
import './Footer.css';

export const Footer = () => {

    const { toaster } = useContext(NotificationContext);

    const handleWhatsapp = ($e) => {
        $e.preventDefault();
        try {
            const newWindow = window.open('https://wa.me/5493885727746?text=¡Hola!%20Quisiera%20más%20información%20acerca%20de%20Plax.', '_blank');
            if (!newWindow || newWindow.closed || typeof newWindow.closed === 'undefined') {
                throw new Error('Please allow popups for this website');
            }
        } catch (e) {
            console.error(e)
            toaster['error']({
                message: 'Error al abrir WhatsApp.',
                description: "No se pudo abrir WhatsApp. Verifica tu conexión.",
                duration: 3
            })
        }
    }

    return (
        <footer className='footer'>
            <Link to='/'>
                <figure className='footer__isologo'>
                    <img src={Isologo} height={40} width={40} alt="Hotel" />
                    <figcaption>&copy; 2025 PLAX</figcaption>
                    {/* INTEGRANTES DEL GRUPO HIA */}
                    <figcaption>Integrantes del Grupo: Yufra, Marcelo Alejandro 4308 -  Barboza, Gonzalo Nicolás 4667 - Yáñez, Sofia Trinidad 4471 - Guerrero Erazo Luis Alberto 4509</figcaption>
                </figure>
            </Link>
        </footer>
    )
}
