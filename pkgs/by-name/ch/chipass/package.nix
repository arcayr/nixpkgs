{
  lib,
  stdenv,
  ctestCheckHook,
  fetchFromCodeberg,

  asciidoctor,
  botan3,
  cmake,
  libargon2,
  libusb1,
  libxtst,
  minizip,
  nix-update-script,
  pcsclite,
  pkgconf,
  qrencode,
  qt6,
  qt6Packages,
  readline,
  wl-clipboard,
  xclip,
  zlib,

  withAutoType ? true,
  withBrowser ? true,
  withBrowserPasskeys ? true,
  withFDOSecrets ? true,
  withKeeShare ? true,
  withNetworking ? true,
  withSSHAgent ? true,
  withYubiKey ? true,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "chipass";
  version = "2026.09.0";

  src = fetchFromCodeberg {
    owner = "ChiPass";
    repo = "ChiPass";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6nA7NziEgiQolhx5cGdyZZTJ5JcKWz9WQOiJ3JiZ6UQ=";
  };

  nativeBuildInputs = [
    asciidoctor
    cmake
    pkgconf
    qt6.qttools
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    botan3
    libargon2
    libusb1
    libxtst
    minizip
    pcsclite
    qrencode
    readline
    qt6.qt5compat
    qt6.qtbase
    qt6.qtsvg
    qt6.qttranslations
    qt6Packages.appstream-qt
    zlib
  ];

  cmakeFlags = [
    (lib.cmakeFeature "CHIPASS_BUILD_TYPE" "Release")
    (lib.cmakeBool "CHIPASS_WITH_TESTS" true)
    (lib.cmakeBool "CHIPASS_WITH_UPDATE_CHECK" false)
    (lib.cmakeBool "CHIPASS_WITH_AUTOTYPE" withAutoType)
    (lib.cmakeBool "CHIPASS_WITH_BROWSER" withBrowser)
    (lib.cmakeBool "CHIPASS_WITH_BROWSER_PASSKEYS" withBrowserPasskeys)
    (lib.cmakeBool "CHIPASS_WITH_KEESHARE" withKeeShare)
    (lib.cmakeBool "CHIPASS_WITH_NETWORKING" withNetworking)
    (lib.cmakeBool "CHIPASS_WITH_SSHAGENT" withSSHAgent)
    (lib.cmakeBool "CHIPASS_WITH_YUBIKEY" withYubiKey)
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    (lib.cmakeFeature "CHIPASS_WL_COPY_EXECUTABLE" (lib.getExe' wl-clipboard "wl-copy"))
    (lib.cmakeFeature "CHIPASS_XCLIP_EXECUTABLE" (lib.getExe xclip))
    (lib.cmakeBool "CHIPASS_WITH_FDOSECRETS" withFDOSecrets)
  ];

  doCheck = true;
  nativeCheckInputs = [ ctestCheckHook ];

  # require a display.
  disabledTests = [
    "cli"
    "entrymodel"
    "gui"
    "guibrowser"
    "guifdosecrets"
    "guipixmaps"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Qt6 offline password manager with many features";
    longDescription = ''
      A fork of KeePassXC, ported to Qt6. Accessible via native
      cross-platform GUI and CLI, and supports browser integration using the
      KeePassXC Browser Extension.
    '';
    homePage = "https://chipass.org/";
    changelog = "https://codeberg.org/chipass/chipass/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [
      arcayr
    ];
    mainProgram = "ChiPass";
    platforms = lib.platforms.linux;
  };
})
