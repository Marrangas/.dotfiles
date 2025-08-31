#!/usr/bin/env bash

readonly BOLD=$(tput bold)
readonly NORMAL=$(tput sgr0)

set -eEo pipefail

readonly SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
readonly CURRENT_DIR_BASENAME=$(basename "$(pwd)")

declare -ra EXCLUDE_DIRS=(
	 # make only search for directories with  .tf files inside of them
	"^\.$"
	"\.git$"
	"\.terraform$"
	"scripts$"
	"data$"
	"templates$"
	"modules$"
	"poc$"
	"docs$"
)

ctrl_c() {
	echo -e "\n${BOLD}[ ] Force Exit${NORMAL}"
	exit 1
}

cleanup() {
	echo -e "\n${BOLD}[ ] Cleaning up...${NORMAL}"
	tput cnorm > /dev/null 2>&1 || true
	find "${SCRIPT_DIR}" -type f -name "*.tfplan" -delete || true
	echo -e "${BOLD}[ ] Cleanup complete.${NORMAL}"
}

trap 'ctrl_c' INT
trap 'cleanup' EXIT

usage() {
	echo "Usage: $0 [OPTIONS]"
	echo "Options:"
	echo "${BOLD} -h, --help ${NORMAL}              Display this help message"
	echo "${BOLD} -p, --plan ${NORMAL} <opt-arg>    Plan all Terraform state files or those matching a glob pattern"
	echo "${BOLD} -a, --apply ${NORMAL}<opt-arg>    Apply all Terraform state files or those matching a glob pattern"
}

ask_confirm() {
	read -r -p "${1} [Yes/No]: " response
	case "${response}" in
		[yY][eE][sS]|[yY]) return 0 ;;
		*) return 1 ;;
	esac
}

setup_tmp_dir() {
	local tmp_dir="/tmp/tfall/${CURRENT_DIR_BASENAME}"
	mkdir -p "${tmp_dir}"
	find "${tmp_dir}/" -type f -delete || true
	echo "Temporary directory for Terraform outputs: ${tmp_dir}"
}

tf_parser() {
	local tf_filter="${1:-.*}"
	local exclude_regex
	IFS="|" read -r -a exclude_regex <<< "${EXCLUDE_DIRS[*]}"

	find . -maxdepth 1 -type d \
		| sed -E "/${exclude_regex[*]}/d" \
		| sed -n "/${tf_filter}/p" \
		| sed 's/^\.\///' \
		| while read -r dir; do
			if find "${dir}" -maxdepth 1 -type f -name "*.tf" -print -quit | grep -q .; then
				echo "${dir}"
			fi
		done
}

tf_init() {
	local workspace_name="$1"
	local tf_dir="$2"
	local init_output

	# echo -e "\tTERRAFORM INIT, workspace '${workspace_name}' in '${tf_dir}'"
	init_output=$(terraform init -upgrade -no-color 2>&1)

	if grep -q "^Error:" <<< "${init_output}"; then
		echo -e "${BOLD}INIT ERROR:${NORMAL} State workspace '${workspace_name}' in '${tf_dir}' has errors." | tee -a "/tmp/tfall/${CURRENT_DIR_BASENAME}/${workspace_name}-$(basename "${tf_dir}").tfshow"
		echo "${init_output}" >> "/tmp/tfall/${CURRENT_DIR_BASENAME}/${workspace_name}-$(basename "${tf_dir}").tfshow"
		return 1
	fi
	return 0
}
export -f tf_init

tf_plan() {
	local workspace_name="$1"
	local tf_dir="$2"
	local plan_output
	local tfplan_file="${workspace_name}.tfplan"

	# echo -e "\tTERRAFORM PLAN, workspace '${workspace_name}' in '${tf_dir}'"
	plan_output=$(terraform plan -lock=false -out="${tfplan_file}" -no-color 2>&1)

	if grep -q "Error:" <<< "${plan_output}"; then
		echo -e "${BOLD}INIT ERROR:${NORMAL} State workspace '${workspace_name}' in '${tf_dir}' has errors." | tee -a "/tmp/tfall/${CURRENT_DIR_BASENAME}/${workspace_name}-$(basename "${tf_dir}").tfshow"
		echo "${plan_output}" >> "/tmp/tfall/${CURRENT_DIR_BASENAME}/${workspace_name}-$(basename "${tf_dir}").tfshow"
		return 1
	elif grep -q "No changes." <<< "${plan_output}"; then
		# echo -e "\t${BOLD}SKIPPED:${NORMAL} No changes for workspace '${workspace_name}' in '${tf_dir}'."
		rm -f "${tfplan_file}" || true
	else
		# echo -e "\t${BOLD}PLAN SUCCESS:${NORMAL} Showing plan for workspace '${workspace_name}' in '${tf_dir}'."
		terraform show -no-color "${tfplan_file}" | tail -n+6 | tee "/tmp/tfall/${CURRENT_DIR_BASENAME}/${workspace_name}-$(basename "${tf_dir}").tfshow"
	fi
	return 0
}
export -f tf_plan

loop_workspace() {
	local tf_dir="$1"
	local initial_dir_cleanup=0

	if [[ -z "${tf_dir}" ]]; then
		# echo "${BOLD}Error:${NORMAL} No Terraform directory provided to loop_workspace." >&2
		return 1
	fi

	echo -e "\n${BOLD}Terraform executing in: '${tf_dir}'${NORMAL}"

	(
		pushd "${tf_dir}" > /dev/null || { echo "${BOLD}Error:${NORMAL} Failed to change directory to '${tf_dir}'." >&2; exit 1; }

		if [[ -d ".terraform" ]]; then
			# echo -e "\tFound existing '.terraform' directory. It will not be removed initially."
			initial_dir_cleanup=1
		# else
			# echo -e "\tNo '.terraform' directory found. It will be removed after processing."
		fi

		tf_init "full_environment" "$(pwd)" || return 1

		local workspace_list
		workspace_list=$(terraform workspace list | sed -E '/^$/d; s/[^a-zA-Z0-9*]//g' | grep -v 'default' | grep -v '*')

		if [[ "$(basename "$(pwd)")" =~ ^workspace$ || -n "${workspace_list}" ]]; then
			if [[ -n "${workspace_list}" ]]; then
				# echo -e "\tFound multiple workspaces: ${workspace_list}"
				for workspace_name in ${workspace_list}; do
					# echo -e "\tSelecting workspace: '${workspace_name}'"
					terraform workspace select "${workspace_name}" || { echo "${BOLD}Error:${NORMAL} Failed to select workspace '${workspace_name}'." >&2; return 1; }
					tf_init "${workspace_name}" "$(pwd)" || return 1
					tf_plan "${workspace_name}" "$(pwd)" || return 1
				done
			else
				# echo -e "\tCurrent directory name is 'workspace' but no additional workspaces found. Processing 'default'."
				tf_plan "default" "$(pwd)" || return 1
			fi
		else
			# echo -e "\tProcessing 'default' workspace."
			tf_plan "default" "$(pwd)" || return 1
		fi

		if [[ "${initial_dir_cleanup}" -eq 0 ]]; then
			# echo -e "\tRemoving '.terraform' directory."
			rm -rf ".terraform"
		fi

		find . -type f -name "*.tfplan" -delete || true

	)
	return $?
}
export -f loop_workspace

parse_tfshow_filename() {
	local filename="$1"
	if [[ ! "${filename}" =~ ^([^-]+)-(.*)\.tfshow$ ]]; then
		echo "${BOLD}Error:${NORMAL} Invalid tfshow filename format: '${filename}'" >&2
		return 1
	fi
	ENVIRONMENT="${BASH_REMATCH[1]}"
	PROJECT="${BASH_REMATCH[2]}"
	return 0
}

tf_apply_plans() {
	local tmp_tfall_dir="/tmp/tfall/${CURRENT_DIR_BASENAME}"

	if ! ls -1 "${tmp_tfall_dir}/"*.tfshow 1>/dev/null 2>&1; then
		echo "${BOLD}No Terraform plan outputs (.tfshow files) found to apply in ${tmp_tfall_dir}.${NORMAL}"
		return 0
	fi

	for tfshow_file in "${tmp_tfall_dir}/"*.tfshow; do
		local filename=$(basename "${tfshow_file}")
		local ENVIRONMENT PROJECT # Declare as local for safety

		parse_tfshow_filename "${filename}" || continue # Skip if filename is invalid

		echo -e "\n${BOLD}Attempting to apply: ${filename} (Environment: ${ENVIRONMENT}, Project: ${PROJECT})${NORMAL}"

		local project_full_path="${SCRIPT_DIR}/${PROJECT}"

		if [[ ! -d "${project_full_path}" ]]; then
			echo "${BOLD}Error:${NORMAL} Project directory '${project_full_path}' not found for application." >&2
			continue
		fi

		(
			pushd "${project_full_path}" > /dev/null || { echo "${BOLD}Error:${NORMAL} Failed to change directory to '${project_full_path}'." >&2; exit 1; }

			tf_init "full_environment" "$(pwd)" || return 1

			local tfplan_file="${ENVIRONMENT}.tfplan"
			if [[ ! -f "${tfplan_file}" ]]; then
				echo "${BOLD}Error:${NORMAL} Terraform plan file '${tfplan_file}' not found in '${project_full_path}'. Skipping apply." >&2
				return 1
			fi

			if [[ "${ENVIRONMENT}" == "default" ]]; then
				# echo -e "\tApplying 'default' workspace plan for '${PROJECT}'."
				terraform apply "${tfplan_file}" || { echo "${BOLD}Error:${NORMAL} Terraform apply failed for 'default' workspace in '${PROJECT}'." >&2; return 1; }
			else
				# echo -e "\tSelecting workspace '${ENVIRONMENT}' for '${PROJECT}'."
				terraform workspace select "${ENVIRONMENT}" || { echo "${BOLD}Error:${NORMAL} Failed to select workspace '${ENVIRONMENT}' in '${PROJECT}'." >&2; return 1; }
				# echo -e "\tApplying plan for workspace '${ENVIRONMENT}' in '${PROJECT}'."
				terraform apply "${tfplan_file}" || { echo "${BOLD}Error:${NORMAL} Terraform apply failed for workspace '${ENVIRONMENT}' in '${PROJECT}'." >&2; return 1; }
			fi
			# echo -e "${BOLD}SUCCESS:${NORMAL} Applied '${filename}'."
		) || { echo "${BOLD}Error:${NORMAL} Failed to apply ${filename}." >&2; continue; }
	done
}

main() {
	if [[ -z "$1" ]]; then
		usage
		exit 0
	fi

	local target_path=""
	local tf_filter=""

	while [ $# -gt 0 ]; do
		case "$1" in
			-h | --help)
				usage
				exit 0
				;;
			--path)
				shift
				target_path="$1"
				;;
			-p | --plan)
				tf_filter="${2:-.*}"
				shift
				if [[ "$2" != -* ]]; then
					shift
				fi

				setup_tmp_dir || exit 1

				echo "${BOLD}Planning the following Terraform directories:${NORMAL}"
				local directories_to_plan
				directories_to_plan=$(tf_parser "${tf_filter}")

				if [[ -z "${directories_to_plan}" ]]; then
					echo "${BOLD}No Terraform directories found matching the filter '${tf_filter}'.${NORMAL}"
					exit 0
				fi

				echo "${directories_to_plan}"

				if ask_confirm "${BOLD}Do you want to make a Terraform plan to the listed directories?${NORMAL}"; then
					echo -e "${BOLD}EXECUTING PLAN...${NORMAL}" ; sleep 1
				else
					echo -e "${BOLD}PLAN CANCELLED${NORMAL}" && exit 2
				fi

				echo "${directories_to_plan}" | parallel -j 75% "loop_workspace {}" || exit 1
				;;
			-a | --apply)
				shift
				tf_apply_plans || exit 0
				;;
			*)
				echo "${BOLD}Invalid option:${NORMAL} '$1'" >&2
				usage
				exit 1
				;;
		esac
		shift
	done
}

main "$@"
