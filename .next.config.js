module.exports = {
  webpack: (config) => {
    config.resolve.fallback = { fs: false, path: false, os: false, net: false, tls: false, crypto: false, stream: false, timers: false, process: false, zlib: false, cardinal: false, buffer: false, events: false, util: false };
    return config;
  },
  env: {
    NEXTAUTH_URL: 'https://dash.example.com', // http://localhost:3000 for dev purposes, also change in .env
    SECRET_COOKIE_PASSWORD: "", // cookie pass, 32 chars min
    MYSQL_HOST: "localhost",
    MYSQL_USER: "dashboardsy",
    MYSQL_PASSWORD: "",
    MYSQL_DATABASE: "dashboardsy",
    DISCORD_CLIENT_ID: "",
    DISCORD_CLIENT_SECRET: "",
  },
  images: {
    domains: ['cdn.discordapp.com', 'media.discordapp.net'],
  },
//  productionBrowserSourceMaps: true, // Very useful for debugging errors in production
};
