FROM alpine:edge
MAINTAINER Anton Kochkov <anton.kochkov@gmail.com>
# TODO: Add antibody
RUN apk add --no-cache alpine-sdk bash bash-doc bash-completion \
	coreutils python3 python3-dev tmux neovim tig zsh mc
RUN addgroup -g 1000 -S user && adduser -u 1000 -D -S akochkov -G user -G abuild
RUN echo "akochkov ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
# Write abuild configuration
RUN sed -i.bkp -e \
	's/#PACKAGER="Your Name <your@email.address>"/PACKAGER="Anton Kochkov <anton.kochkov@gmail.com>"/g' \
	/etc/abuild.conf
RUN sed -i.bkp -e \
	's/#MAINTAINER="$PACKAGER"/MAINTAINER="$PACKAGER"/g' \
	/etc/abuild.conf
# Prepare the distfiles directories
RUN mkdir -p /var/cache/distfiles && chmod g+w /var/cache/distfiles
# Set the proper shell
ENV SHELL /bin/bash
ENV TERM xterm-256color
# Copy dotfiles
COPY dotfiles /home/akochkov
RUN chown -R akochkov:user /home/akochkov
USER akochkov
WORKDIR /home/akochkov
# Set up the git
RUN git config --global user.name "Anton Kochkov"
RUN git config --global user.email "anton.kochkov@gmail.com"
# Setup the NeoVim
RUN pip3 install -U --user --no-color pynvim
RUN nvim +PlugInstall +qall > /dev/null
# Get the ports
RUN git clone git://git.alpinelinux.org/aports
# Generate the keys?
# TODO: Persist between runs
# abuild-keygen -a -i

ENTRYPOINT ["/bin/bash"]

