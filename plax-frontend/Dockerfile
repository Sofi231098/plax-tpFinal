# ---- Etapa de build ----
FROM node:18-alpine AS build
WORKDIR /app

# Copiar solo package.json primero (para aprovechar cache)
COPY package*.json ./
RUN npm install

# Ahora copiamos el resto del proyecto
COPY . .
RUN npm run build

# ---- Etapa final: servir archivos estáticos ----
FROM nginx:stable-alpine

# Copiamos la carpeta generada por Vite
COPY --from=build /app/dist /usr/share/nginx/html

# Copiamos el script que inyectará config.js
COPY inject-config.sh /inject-config.sh
RUN chmod +x /inject-config.sh

EXPOSE 80

# Usamos nuestro script como entrypoint
CMD ["/inject-config.sh"]