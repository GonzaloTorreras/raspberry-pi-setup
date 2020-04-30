# Nginx Docker Reverse Proxy

Auto contained deployment of Nginx + Certbot (Let's Encrypt) - ready to serve certs

### Configure Nginx

After pulling the project, configure all the websites that Nginx will serve (Only HTTP, certbot will take care of the HTTPS configurations)

```
conf.d/default.conf
```

### Certbot: Get a new certificate (1st time only)

Get into the runing container

```
sudo docker exec -it nginxWithCerts bash
```

Launch the autoconfiguration process

```
certbot --nginx
```

After following the propmted options your website will be served as https:// and your certificates will be located at

```
./letsencrypt/live/yourwebsite/
```

### Certbot: Renew certificates

To obtain a new or tweaked version of the certificates in the future,
simply run certbot again with the "certonly" option.

To non-interactively renew _all_ of your certificates, run "certbot renew"
