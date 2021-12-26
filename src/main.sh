use std::print::log;

declare -r _marketplace_prefix="https://marketplace.visualstudio.com/items?itemName=";

declare _vscode_ext_dir && _vscode_ext_dir="$(
	if command -v code 1>/dev/null; then {
		for _dir in '.vscode-remote' '.vscode-web' '.vscode'; do {
			if test -e "$HOME/$_dir"; then {
				printf '%s\n' "$HOME/$_dir/extensions";
				break;
			} else {
				continue;
			} fi
		} done
	} else {
		printf '%s\n' "$HOME/.vscode-remote/extensions";
	} fi
)";

function install_mp_ext() {
	declare -r _vsix_id="${1##*=}";
	local _ext_author _ext_codename _ext_version _dw_link;
	IFS='.' read -r _ext_author _ext_codename <<<"$_vsix_id";
	declare -r _vsix_page_url="${_marketplace_prefix}$_vsix_id";

	log::info "Getting version information for $_vsix_id";
	[[ "$(curl -sL "$_vsix_page_url")" =~ \"VersionValue\":\"[0-9]+?.?[0-9]+?.?[0-9]+?\" ]] \
	&& _ext_version="$(sed -E 's/.*"([^"]+)".*/\1/' <<<"${BASH_REMATCH[0]}")";
	
	# Download link
	_dw_link="$(printf 'https://marketplace.visualstudio.com/_apis/public/gallery/publishers/%s/vsextensions/%s/%s/vspackage\n' "$_ext_author" "$_ext_codename" "$_ext_version")";
	declare _tmp_dir="/tmp/.${RANDOM}_$$";
	local _dw_file="$_tmp_dir/pkg.vsix";
	rm -rf "$_tmp_dir" && mkdir -p "$_tmp_dir";
	trap "rm -rf $_tmp_dir" ERR EXIT;

	log::info "Downloading $_vsix_id";
	wget -q "$_dw_link" -O - | gzip -dc > "$_dw_file";
	if command -v code 1>/dev/null; then {
		log::info "Installing $_vsix_id natively";
		code --install-extension "$_dw_file" 1>/dev/null;
	} else {
		log::info "Installing $_vsix_id in docker mode";
		declare _ext_dir="${_vscode_ext_dir}/${_vsix_id,,}-${_ext_version}";
		rm -rf "$_ext_dir";
		unzip -qqo "$_dw_file" -d "$_tmp_dir";
		mv "$_tmp_dir/extension" "$_ext_dir";
	} fi

	rm -rf "$_tmp_dir"

}

function main() {
	declare -r _inputs=("$@");

	for _input in "${_inputs[@]}"; do {
		# Run in parallel
		install_mp_ext "$_input" &
	} done

	wait;
}

