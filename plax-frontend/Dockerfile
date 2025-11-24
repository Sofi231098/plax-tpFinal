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
WORKDIR /usr/share/nginx/html
COPY --from=build /app/dist ./

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]