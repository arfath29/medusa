module.exports = {
    projectConfig: {
        redis_url: process.env.REDIS_URL,
        database_url: process.env.DATABASE_URL,
        database_type: "postgres",
        jwt_secret: supersecretkey || "supersecret",
        cookie_secret: cookiekey123 || "supersecret",
        store_cors: medusa-alb-629619371.ap-south-1.elb.amazonaws.com || "http://localhost:8000",
        admin_cors: medusa-alb-629619371.ap-south-1.elb.amazonaws.com || "http://localhost:7001",
    },
    plugins: []
};
