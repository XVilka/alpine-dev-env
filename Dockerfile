FROM alpine:edge
MAINTAINER Anton Kochkov <anton.kochkov@gmail.com>

# Some variables
ARG username=akochkov
ARG realname="Anton Kochkov"
ARG email="anton.kochkov@gmail.com"
ARG keyname="anton.kochkov@gmail.com-5db6cdc1"

# TODO: Add antibody
RUN apk add --no-cache alpine-sdk bash bash-doc bash-completion \
	coreutils man python3 python3-dev tmux neovim tig zsh mc
RUN addgroup -g 1000 -S user && adduser -u 1000 -D -S ${username} -G user -G abuild
RUN echo "${username} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Write abuild configuration
RUN sed -i.bkp -e \
	's/#PACKAGER="Your Name <your@email.address>"/PACKAGER="${realname} <${email}>"/g' \
	/etc/abuild.conf
RUN sed -i.bkp -e \
	's/#MAINTAINER="$PACKAGER"/MAINTAINER="$PACKAGER"/g' \
	/etc/abuild.conf

# Copy the keys
RUN mkdir -p /home/${username}/.abuild
COPY ${keyname}.rsa /home/${username}/.abuild/${keyname}.rsa
COPY ${keyname}.rsa.pub /home/${username}/.abuild/${keyname}.rsa.pub
RUN echo "PACKAGER_PRIVKEY=\"/home/${username}/.abuild/${keyname}.rsa\"" > \
	/home/${username}/.abuild/abuild.conf

# Prepare the distfiles directories
RUN mkdir -p /var/cache/distfiles && chmod g+w /var/cache/distfiles
RUN sed -i.bkp -e \
	'1s;^;/home/${username}/packages/testing\n;' \
	/etc/apk/repositories && \
	sed -i.bkp -e \
	'1s;^;/home/${username}/packages/community\n;' \
	/etc/apk/repositories && \
	sed -i.bkp -e \
	'1s;^;/home/${username}/packages/main\n;' \
	/etc/apk/repositories

# Set the proper shell
# TODO: Use zsh
ENV SHELL /bin/bash
ENV TERM xterm-256color
# Copy dotfiles
COPY dotfiles /home/${username}
RUN chown -R ${username}:user /home/${username}
USER ${username}
WORKDIR /home/${username}
# Set up the git
RUN git config --global user.name "${realname}"
RUN git config --global user.email "${email}"
# Setup the NeoVim
RUN pip3 install -U --user --no-color pynvim
RUN nvim +PlugInstall +qall > /dev/null
# Get the ports
RUN git clone git://git.alpinelinux.org/aports

ENTRYPOINT ["/bin/bash"]

