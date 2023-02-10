# Thanks, DNX Solutions!
FROM dnxsolutions/ecs-deploy:2.2.1

# Pull the Action's contents in to the image alongside the base image's scripts
COPY action/ /work/
COPY LICENSE.txt README.md /work/

# Ensure we have permission to run our scripts
RUN chmod a+x /work/**/*.sh

# Run the Action's main script
ENTRYPOINT ["/work/entrypoint.sh"]
