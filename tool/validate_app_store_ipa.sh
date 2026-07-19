#!/bin/bash

set -euo pipefail

ipa_path="${1:?Usage: validate_app_store_ipa.sh IPA_PATH [VERSION] [BUILD] [XCODE_BUILD] [HOST_OS_BUILD]}"
expected_version="${2:-1.1.2}"
expected_build="${3:-4}"
expected_xcode_build="${4:-17F113}"
expected_host_os_build="${5:-}"

if [[ ! -f "${ipa_path}" ]]; then
  echo "IPA not found: ${ipa_path}" >&2
  exit 1
fi

work_path="$(mktemp -d "${TMPDIR:-/tmp}/beautyontapp-ipa.XXXXXX")"
trap 'rm -rf "${work_path}"' EXIT

ditto -x -k "${ipa_path}" "${work_path}"
app_path="$(find "${work_path}/Payload" -maxdepth 1 -type d -name '*.app' -print -quit)"

if [[ -z "${app_path}" ]]; then
  echo "No app bundle found in IPA: ${ipa_path}" >&2
  exit 1
fi

info_plist="${app_path}/Info.plist"
actual_version="$(plutil -extract CFBundleShortVersionString raw -o - "${info_plist}")"
actual_build="$(plutil -extract CFBundleVersion raw -o - "${info_plist}")"
actual_xcode_build="$(plutil -extract DTXcodeBuild raw -o - "${info_plist}")"
actual_host_os_build="$(plutil -extract BuildMachineOSBuild raw -o - "${info_plist}")"
actual_sdk_name="$(plutil -extract DTSDKName raw -o - "${info_plist}")"
actual_sdk_build="$(plutil -extract DTSDKBuild raw -o - "${info_plist}")"

[[ "${actual_version}" == "${expected_version}" ]] || {
  echo "Version mismatch: expected ${expected_version}, found ${actual_version}" >&2
  exit 1
}
[[ "${actual_build}" == "${expected_build}" ]] || {
  echo "Build mismatch: expected ${expected_build}, found ${actual_build}" >&2
  exit 1
}
[[ "${actual_xcode_build}" == "${expected_xcode_build}" ]] || {
  echo "Xcode build mismatch: expected ${expected_xcode_build}, found ${actual_xcode_build}" >&2
  exit 1
}
if [[ -n "${expected_host_os_build}" ]]; then
  [[ "${actual_host_os_build}" == "${expected_host_os_build}" ]] || {
    echo "Build host mismatch: expected ${expected_host_os_build}, found ${actual_host_os_build}" >&2
    exit 1
  }
elif [[ ! "${actual_host_os_build}" =~ ^25[A-Z][0-9]+$ ]]; then
  echo "Unsupported build host: expected a stable macOS 26.x build, found ${actual_host_os_build}" >&2
  exit 1
fi
[[ "${actual_sdk_name}" == "iphoneos26.5" ]] || {
  echo "SDK name mismatch: expected iphoneos26.5, found ${actual_sdk_name}" >&2
  exit 1
}
[[ "${actual_sdk_build}" == "23F81a" ]] || {
  echo "SDK build mismatch: expected 23F81a, found ${actual_sdk_build}" >&2
  exit 1
}

manifest_count=0
while IFS= read -r manifest_path; do
  manifest_count=$((manifest_count + 1))
  plutil -lint "${manifest_path}" >/dev/null
done < <(find "${app_path}" -type f -name 'PrivacyInfo.xcprivacy' -print | sort)

if [[ "${manifest_count}" -eq 0 ]]; then
  echo "No privacy manifests found in IPA." >&2
  exit 1
fi

codesign --verify --deep --strict --verbose=2 "${app_path}"

while IFS= read -r bundle_plist; do
  nested_host="$(plutil -extract BuildMachineOSBuild raw -o - "${bundle_plist}" 2>/dev/null || true)"
  nested_xcode="$(plutil -extract DTXcodeBuild raw -o - "${bundle_plist}" 2>/dev/null || true)"
  nested_sdk="$(plutil -extract DTSDKBuild raw -o - "${bundle_plist}" 2>/dev/null || true)"

  if [[ -n "${nested_host}" && "${nested_host}" != "${actual_host_os_build}" ]]; then
    echo "Nested build host mismatch in ${bundle_plist#${app_path}/}: ${nested_host}" >&2
    exit 1
  fi
  if [[ -n "${nested_xcode}" && "${nested_xcode}" != "${expected_xcode_build}" ]]; then
    echo "Nested Xcode mismatch in ${bundle_plist#${app_path}/}: ${nested_xcode}" >&2
    exit 1
  fi
  if [[ -n "${nested_sdk}" && "${nested_sdk}" != "23F81a" ]]; then
    echo "Nested SDK mismatch in ${bundle_plist#${app_path}/}: ${nested_sdk}" >&2
    exit 1
  fi
done < <(find "${app_path}" -type f -name 'Info.plist' -print | sort)

echo "IPA validation passed: version ${actual_version} (${actual_build}), host ${actual_host_os_build}, Xcode ${actual_xcode_build}, SDK ${actual_sdk_name} (${actual_sdk_build}), ${manifest_count} privacy manifests, strict signature valid."
