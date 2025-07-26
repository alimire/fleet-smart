FROM odoo:17

USER root
RUN apt-get update && apt-get install -y \
    libxml2-dev libxslt1-dev \
    && rm -rf /var/lib/apt/lists/*

COPY ./addons /mnt/extra-addons

USER odoo
