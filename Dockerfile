FROM node:14.18-alpine AS development

RUN mkdir -p /usr/src/app/node_modules && chown -R node:node /usr/src/app

COPY package.json yarn.lock ./

WORKDIR /usr/src/app

RUN yarn global add @nestjs/cli
RUN yarn global add rimraf
RUN yarn install --frozen-lockfile --only=development

COPY --chown=node:node . . 

# DON'T RUN CONTAINER AS ROOT
USER node


CMD ["yarn", "start:development"] --only=development

# PRODUCTION

FROM node:14.18-alpine AS production

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

WORKDIR /usr/src/app

COPY package.json yarn.lock ./

RUN yarn install --frozen-lockfile --only=production

COPY --chown=node:node . .

COPY --chown=node:node --from=development /usr/src/app/dist ./dist

# DON'T RUN CONTAINER AS ROOT
USER node

CMD ["node", "dist/main"] --only=production