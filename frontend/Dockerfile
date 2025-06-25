FROM node:lts-alpine AS runtime
WORKDIR /app

COPY . .

RUN npm install
RUN npm run build

ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=1001

EXPOSE 1001
CMD node ./dist/server/entry.mjs