resource "kubectl_manifest" "nginx-config" {
  yaml_body  = <<-EOF

kind: ConfigMap
apiVersion: v1
metadata:
  name: ${var.instance}-nginx
  namespace: "${var.namespace}"
  labels: ${jsonencode(local.common-labels)}
data:
  nginx.conf: |
    worker_processes  5;
    events {
    }
    http {
        include    /etc/nginx/mime.types;
        server {
            listen 3000;
            server_name $${NGINX_HOST};
            root /var/www/htdocs;
            index index.php;
            access_log /var/log/nginx/access.log;
            error_log /var/log/nginx/error.log;
            location ~ [^/]\.php(/|$) {
                # try_files $uri =404;
                fastcgi_split_path_info ^(.+?\.php)(/.*)$;
                fastcgi_pass 127.0.0.1:9000;
                fastcgi_index index.php;
                include fastcgi_params;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                fastcgi_param PATH_INFO $fastcgi_path_info;
            }
            location / {
                try_files $uri $uri/ index.php;
            }
            location /api {
                if ( !-e $request_filename) {
                    rewrite ^.* /api/index.php last;
                }
            }
        }
    }
  EOF
}
