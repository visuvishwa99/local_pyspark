FROM public.ecr.aws/glue/aws-glue-libs:5

USER hadoop

RUN python3 -m pip install --no-cache-dir --user jupyterlab==4.6.6

ENV PATH="/home/hadoop/.local/bin:${PATH}"

USER root

RUN set -eu; \
    sed -ri 's/^spark\.ui\.enabled[[:space:]]+.*/spark.ui.enabled                 true/' /etc/spark/conf/spark-defaults.conf; \
    if ! grep -q '^spark\.ui\.port' /etc/spark/conf/spark-defaults.conf; then \
        printf '\nspark.ui.port                    4040\n' >> /etc/spark/conf/spark-defaults.conf; \
    fi; \
    grep -q '^spark\.ui\.enabled[[:space:]]\+true$' /etc/spark/conf/spark-defaults.conf

USER hadoop
WORKDIR /home/hadoop/workspace

EXPOSE 8888 4040

ENTRYPOINT ["bash", "-lc"]
CMD ["token=\"${JUPYTER_TOKEN:-glue-local}\"; exec jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --ServerApp.root_dir=/home/hadoop/workspace --IdentityProvider.token=\"$token\""]
