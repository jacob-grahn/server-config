server {
	root /home/jiggmin/cdn;
	server_name cdn.jiggmin.com;

	location / {
		expires 30d;
		add_header Cache-Control public;
		proxy_cache cdn-files;
		proxy_cache_valid any 1m;
		proxy_cache_valid 200 302 30m;
		proxy_pass http://jiggmin.s3-website-us-east-1.amazonaws.com/;
	}
}