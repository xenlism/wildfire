#!/usr/bin/env bash
# =============================================================================
# wildfire-symlink-rdns.sh
# สร้าง reverse-DNS symlinks สำหรับ xenlism/wildfire icon theme
# รองรับโครงสร้างจริงของ repo: icons/<ThemeName>/Apps/ (flat, scalable SVG)
#
# - ไม่ลบ / ไม่แก้ไฟล์เดิม
# - สร้าง symlink เท่านั้น
# - ข้าม symlink / ไฟล์ที่มีอยู่แล้ว
# - รองรับทุก theme variant (Day/Night/Wildfire)
# =============================================================================
set -euo pipefail

# --------------------------------------------------------------------------- #
# CONFIG
# --------------------------------------------------------------------------- #
# Default: repo clone path → icons/
ICONS_BASE="${ICONS_BASE:-$(cd "$(dirname "$0")" && pwd)/icons}"
DRY_RUN=false
VERBOSE=false

# --------------------------------------------------------------------------- #
# MAPPING: ชื่อเก่า (ไฟล์จริงใน repo) → ชื่อ reverse-DNS ใหม่ที่ต้องการ
# คู่ไหนมีอยู่แล้วในโฟลเดอร์ → ข้ามอัตโนมัติ
# --------------------------------------------------------------------------- #
declare -A MAP

# ── GNOME Core Apps ──────────────────────────────────────────────────────────
MAP["nautilus"]="org.gnome.Nautilus"
MAP["gedit"]="org.gnome.gedit"
MAP["eog"]="org.gnome.eog"
MAP["evince"]="org.gnome.Evince"
MAP["totem"]="org.gnome.Totem"
MAP["gnome-terminal"]="org.gnome.Terminal"
MAP["gnome-calculator"]="org.gnome.Calculator"
MAP["gnome-calendar"]="org.gnome.Calendar"
MAP["gnome-clocks"]="org.gnome.clocks"
MAP["gnome-contacts"]="org.gnome.Contacts"
MAP["gnome-maps"]="org.gnome.Maps"
MAP["gnome-music"]="org.gnome.Music"
MAP["gnome-photos"]="org.gnome.Photos"
MAP["gnome-weather"]="org.gnome.Weather"
MAP["gnome-software"]="org.gnome.Software"
MAP["gnome-system-monitor"]="org.gnome.SystemMonitor"
MAP["gnome-screenshot"]="org.gnome.Screenshot"
MAP["gnome-disks"]="org.gnome.DiskUtility"
MAP["gnome-logs"]="org.gnome.Logs"
MAP["gnome-log"]="org.gnome.Logs"
MAP["gnome-characters"]="org.gnome.Characters"
MAP["gnome-tweaks"]="org.gnome.tweaks"          # already exists but wrong case variant
MAP["gnome-tweak-tool"]="org.gnome.tweaks"
MAP["gnome-documents"]="org.gnome.Documents"
MAP["gnome-books"]="org.gnome.Books"
MAP["gnome-boxes"]="org.gnome.Boxes"
MAP["gnome-chess"]="org.gnome.Chess"
MAP["gnome-mines"]="org.gnome.Mines"
MAP["gnome-sudoku"]="org.gnome.Sudoku"
MAP["gnome-mahjongg"]="org.gnome.Mahjongg"
MAP["gnome-nibbles"]="org.gnome.Nibbles"
MAP["gnome-robots"]="org.gnome.Robots"
MAP["gnome-aisleriot"]="org.gnome.Aisleriot"
MAP["gnome-klotski"]="org.gnome.Klotski"
MAP["gnome-sound-recorder"]="org.gnome.SoundRecorder"
MAP["gnome-remote-desktop"]="org.gnome.RemoteDesktop"
MAP["gnome-subtitles"]="org.gnome.Subtitles"
MAP["gnome-color-manager"]="org.gnome.ColorManager"
MAP["gnome-power-manager"]="org.gnome.PowerManager"
MAP["gnome-power-statistics"]="org.gnome.PowerStats"

# ── GNOME Utilities ───────────────────────────────────────────────────────────
MAP["file-roller"]="org.gnome.FileRoller"
MAP["baobab"]="org.gnome.baobab"
MAP["seahorse"]="org.gnome.Seahorse"
MAP["gparted"]="org.gnome.gparted"
MAP["cheese"]="org.gnome.Cheese"           # (cheese1 also exists)
MAP["cheese1"]="org.gnome.Cheese"
MAP["geary"]="org.gnome.Geary"
MAP["gnote"]="org.gnome.Gnote"
MAP["polari"]="org.gnome.Polari"
MAP["rhythmbox"]="org.gnome.Rhythmbox3"
MAP["rythmbox"]="org.gnome.Rhythmbox3"
MAP["goobox"]="org.gnome.Goobox"
MAP["shotwell"]="org.gnome.Shotwell"
MAP["lollypop"]="org.gnome.Lollypop"
MAP["bijiben"]="org.gnome.Bijiben"
MAP["gnome-font-viewer"]="org.gnome.font-viewer"
MAP["builder"]="org.gnome.Builder"

# ── Text Editors / IDE ────────────────────────────────────────────────────────
MAP["geany"]="org.geany.Geany"
MAP["code"]="com.visualstudio.code"
MAP["code-oss"]="com.visualstudio.code-oss"
MAP["vscode"]="com.visualstudio.code"
MAP["atom"]="io.atom.Atom"
MAP["sublime-text"]="com.sublimetext.three"
MAP["brackets"]="io.brackets.Brackets"
MAP["emacs"]="org.gnu.emacs"
MAP["gvim"]="org.vim.Vim"
MAP["elementary.code"]="io.elementary.code"
MAP["limetext"]="org.limetext.lime"
MAP["textmate"]="com.macromates.TextMate"
MAP["monodevelop"]="com.xamarin.MonoDevelop"
MAP["phpstrom"]="com.jetbrains.PhpStorm"
MAP["qtcreator"]="org.qt-project.qtcreator"

# ── Web / Internet ────────────────────────────────────────────────────────────
MAP["firefox"]="org.mozilla.firefox"
MAP["firefox-esr"]="org.mozilla.firefox"
MAP["firefox-quantum"]="org.mozilla.firefox"
MAP["firefox-aurora"]="org.mozilla.firefox"
MAP["firefox-developer-edition"]="org.mozilla.firefox"
MAP["thunderbird"]="org.mozilla.Thunderbird"
MAP["icedove"]="org.mozilla.Thunderbird"
MAP["iceweasel"]="org.mozilla.firefox"
MAP["chromium"]="org.chromium.Chromium"
MAP["chromium-browser"]="org.chromium.Chromium"
MAP["google-chrome"]="com.google.Chrome"
MAP["opera"]="com.opera.Opera"
MAP["opera-next"]="com.opera.Opera"
MAP["midori"]="org.midori_browser.Midori"
MAP["falkon"]="org.kde.falkon"
MAP["otter-browser"]="org.otter_browser.Otter"
MAP["qupzilla"]="org.qupzilla.Qupzilla"
MAP["yandex-browser-beta"]="ru.yandex.Browser"
MAP["vivaldi"]="com.vivaldi.Vivaldi"
MAP["tor-browser"]="com.github.micahflee.torbrowser-launcher"
MAP["torbrowser"]="com.github.micahflee.torbrowser-launcher"
MAP["torbrowser2"]="com.github.micahflee.torbrowser-launcher"
MAP["epiphany"]="org.gnome.Epiphany"
MAP["abrowser"]="org.abrowser.Abrowser"

# ── Communication ─────────────────────────────────────────────────────────────
MAP["telegram"]="org.telegram.desktop"
MAP["discord"]="com.discordapp.Discord"
MAP["skype"]="com.skype.Client"
MAP["slack"]="com.slack.Slack"
MAP["hipchat"]="com.hipchat.HipChat"
MAP["hipchat-attention"]="com.hipchat.HipChat"
MAP["line"]="com.naver.LinuxApp"
MAP["line-messager"]="com.naver.LinuxApp"
MAP["signal"]="org.signal.Signal"
MAP["empathy"]="org.gnome.Empathy"
MAP["pidgin"]="im.pidgin.Pidgin"
MAP["kopete"]="org.kde.kopete"
MAP["hexchat"]="io.github.Hexchat"
MAP["hexchat2"]="io.github.Hexchat"
MAP["xchat"]="io.github.Hexchat"
MAP["irssi"]="io.github.irssi.Irssi"
MAP["gajim"]="org.gajim.Gajim"
MAP["ekiga"]="org.ekiga.Ekiga"
MAP["birdie"]="com.launchpad.Birdie"
MAP["corebird"]="org.baedert.Corebird"
MAP["messengerfordesktop"]="com.mattermost.Desktop"

# ── Media ─────────────────────────────────────────────────────────────────────
MAP["vlc"]="org.videolan.VLC"
MAP["vlc2"]="org.videolan.VLC"
MAP["gimp"]="org.gimp.GIMP"
MAP["gimp_gimp"]="org.gimp.GIMP"
MAP["inkscape"]="org.inkscape.Inkscape"
MAP["inkscape2"]="org.inkscape.Inkscape"
MAP["blender"]="org.blender.Blender"
MAP["blender-invert"]="org.blender.Blender"
MAP["celluloid"]="io.github.celluloid_player.Celluloid"
MAP["mpv"]="io.mpv.Mpv"
MAP["smplayer"]="net.smplayer.SMPlayer"
MAP["baka-mplayer"]="com.bakamplayer.BakaMPlayer"
MAP["bomi"]="io.github.xylosper.bomi"
MAP["audacity"]="org.audacityteam.Audacity"
MAP["audacious"]="org.atheme.audacious"
MAP["clementine"]="org.clementine_player.Clementine"
MAP["clementine2"]="org.clementine_player.Clementine"
MAP["deadbeef"]="org.deadbeef.Deadbeef"
MAP["amarok"]="org.kde.amarok"
MAP["pithos"]="com.github.pithos.Pithos"
MAP["lmms"]="io.lmms.LMMS"
MAP["ardour"]="org.ardour.Ardour"
MAP["kodi"]="tv.kodi.Kodi"
MAP["kodi2"]="tv.kodi.Kodi"
MAP["handbrake"]="fr.handbrake.ghb"
MAP["pitivi"]="org.pitivi.Pitivi"
MAP["avidemux"]="org.avidemux.Avidemux"
MAP["darktable"]="org.darktable.darktable"
MAP["darktable2"]="org.darktable.darktable"
MAP["digikam"]="org.kde.digikam"
MAP["gwenview"]="org.kde.gwenview"
MAP["gpicview"]="lxde.gpicview"
MAP["ristretto"]="org.xfce.ristretto"
MAP["gthumb"]="org.gnome.gThumb"
MAP["fotowall"]="com.launchpad.Fotowall"
MAP["mypaint"]="org.mypaint.MyPaint"
MAP["minitube"]="com.flavio.Minitube"
MAP["xnoise"]="org.xnoise.Xnoise"
MAP["totem"]="org.gnome.Totem"
MAP["cheese"]="org.gnome.Cheese"

# ── Office / Documents ────────────────────────────────────────────────────────
MAP["libreoffice-writer"]="org.libreoffice.Writer"
MAP["libreoffice-calc"]="org.libreoffice.Calc"
MAP["libreoffice-impress"]="org.libreoffice.Impress"
MAP["libreoffice-draw"]="org.libreoffice.Draw"
MAP["libreoffice-base"]="org.libreoffice.Base"
MAP["libreoffice-math"]="org.libreoffice.Math"
MAP["libreoffice-startcenter"]="org.libreoffice.StartCenter"
MAP["abiword"]="com.abisource.AbiWord"
MAP["scribus"]="net.scribus.Scribus"
MAP["scibus"]="net.scribus.Scribus"
MAP["calibre-gui"]="com.calibre_ebook.calibre"
MAP["calibre-viewer"]="com.calibre_ebook.calibre"
MAP["calibre-ebook-edit"]="com.calibre_ebook.calibre"
MAP["texmaker"]="net.xm1math.Texmaker"
MAP["texstudio"]="org.texstudio.TeXstudio"
MAP["okular"]="org.kde.okular"
MAP["evince"]="org.gnome.Evince"
MAP["fbreader"]="org.fbreader.FBReader"
MAP["gnome-books"]="org.gnome.Books"

# ── Downloads / Torrents ──────────────────────────────────────────────────────
MAP["transmission"]="com.transmissionbt.Transmission"
MAP["transmission-gtk"]="com.transmissionbt.Transmission"
MAP["qbittorrent"]="org.qbittorrent.qBittorrent"
MAP["deluge"]="org.deluge_torrent.deluge"
MAP["deluge0"]="org.deluge_torrent.deluge"
MAP["tixati"]="com.tixati.Tixati"
MAP["tribler"]="org.tribler.Tribler"
MAP["frostwire"]="com.frostwire.FrostWire"
MAP["frostwire2"]="com.frostwire.FrostWire"
MAP["fatrat"]="com.dolezel.Fatrat"
MAP["flareget"]="org.flareget.Flareget"
MAP["jdownloader"]="org.jdownloader.JDownloader"
MAP["jdownloader2"]="org.jdownloader.JDownloader"
MAP["vuze"]="com.azureus.Vuze"

# ── System / Utilities ────────────────────────────────────────────────────────
MAP["gnome-software"]="org.gnome.Software"
MAP["synaptic"]="com.ubuntu.Synaptic"
MAP["virtualbox"]="org.virtualbox.VirtualBox"
MAP["qemu"]="org.qemu.QemuSystem"
MAP["gvim"]="org.vim.Vim"
MAP["guake"]="org.guake.Guake"
MAP["terminator"]="org.gnome_terminator.Terminator"
MAP["terminator2"]="org.gnome_terminator.Terminator"
MAP["terminator3"]="org.gnome_terminator.Terminator"
MAP["lxterminal"]="org.lxde.lxterminal"
MAP["wireshark"]="org.wireshark.Wireshark"
MAP["wireshark2"]="org.wireshark.Wireshark"
MAP["bleachbit"]="org.bleachbit.BleachBit"
MAP["grsync"]="io.github.Grsync"
MAP["deja-dup"]="org.gnome.DejaDup"
MAP["keepass"]="org.keepass2.KeePass2"
MAP["filezilla"]="org.filezilla_project.FileZilla"
MAP["doublecmd"]="com.github.doublecmd.DoubleCmd"
MAP["meld"]="org.gnome.meld"
MAP["glade"]="org.gnome.Glade"
MAP["gitg"]="org.gnome.gitg"
MAP["dconf-editor"]="ca.desrt.dconf-editor"
MAP["gnome-nettool"]="org.gnome.nettool"
MAP["marble"]="org.kde.marble"
MAP["kmail"]="org.kde.kmail"
MAP["kontact"]="org.kde.kontact"
MAP["kaddressbook"]="org.kde.kaddressbook"
MAP["kate"]="org.kde.kate"
MAP["dolphin"]="org.kde.dolphin"
MAP["kolourpaint"]="org.kde.kolourpaint"
MAP["krita"]="org.kde.krita"
MAP["kaffeine"]="org.kde.kaffeine"
MAP["k3b"]="org.kde.k3b"
MAP["konqueror"]="org.kde.konqueror"
MAP["ksnapshot"]="org.kde.ksnapshot"
MAP["ark"]="org.kde.ark"
MAP["spectacle"]="org.kde.spectacle"
MAP["nmap"]="org.nmap.Zenmap"
MAP["gufw"]="com.costales.Gufw"

# ── Games ─────────────────────────────────────────────────────────────────────
MAP["steam"]="com.valvesoftware.Steam"
MAP["steam-install"]="com.valvesoftware.Steam"
MAP["playonlinux"]="org.playonlinux.PlayOnLinux"
MAP["wine"]="org.winehq.Wine"
MAP["wineconfig"]="org.winehq.Wine"
MAP["dosbox"]="com.dosbox.DOSBox"
MAP["gnome-chess"]="org.gnome.Chess"
MAP["five-or-more"]="org.gnome.five-or-more"
MAP["four-in-a-row"]="org.gnome.four-in-a-row"
MAP["lightsoff"]="org.gnome.lightsoff"
MAP["gnome-mines"]="org.gnome.Mines"
MAP["gnome-tetravex"]="org.gnome.Tetravex"
MAP["gnome-sudoku"]="org.gnome.Sudoku"
MAP["gnome-mahjongg"]="org.gnome.Mahjongg"
MAP["ksudoku"]="org.kde.ksudoku"
MAP["stellarium"]="org.stellarium.Stellarium"
MAP["popcorntime"]="io.github.popcorntime.PopcornTime"
MAP["dolphinemu"]="org.DolphinEmu.dolphin-emu"

# ── Cloud / Sync ──────────────────────────────────────────────────────────────
MAP["dropbox"]="com.dropbox.Client"
MAP["bcloud"]="com.bcloud.Bcloud"
MAP["btsync-user"]="com.resilio.Sync"
MAP["crashplan"]="com.crashplan.CrashPlan"
MAP["spideroak"]="com.spideroak.SpiderOak"
MAP["SpiderOak"]="com.spideroak.SpiderOak"

# ── Dev Tools ─────────────────────────────────────────────────────────────────
MAP["postman"]="com.getpostman.Postman"
MAP["Postman"]="com.getpostman.Postman"
MAP["android-studio"]="com.google.AndroidStudio"
MAP["androidstudio"]="com.google.AndroidStudio"
MAP["eclipse"]="org.eclipse.Eclipse"
MAP["netbean"]="org.netbeans.IDE"
MAP["netbean-beta"]="org.netbeans.IDE"
MAP["arduino"]="cc.arduino.IDE"
MAP["gitcola"]="com.github.git-cola.git-cola"
MAP["giteye"]="com.giteye.GitEye"
MAP["devassistant"]="cz.fedorahosted.DevAssistant"
MAP["devassistant2"]="cz.fedorahosted.DevAssistant"
MAP["Thunar"]="org.xfce.Thunar"

# ── Music / Podcast ───────────────────────────────────────────────────────────
MAP["spotify-client"]="com.spotify.Client"
MAP["soundcloud"]="com.soundcloud.Soundcloud"
MAP["pithos"]="com.github.pithos.Pithos"
MAP["gpodder"]="org.gpodder.gPodder"
MAP["quiterss"]="ru.quiterss.QuiteRSS"
MAP["liferea"]="net.sourceforge.liferea"

# ── Misc ──────────────────────────────────────────────────────────────────────
MAP["anki"]="net.ankiweb.Anki"
MAP["calibre-gui"]="com.calibre_ebook.calibre"
MAP["redshift"]="com.jonls.Redshift"
MAP["screencast"]="org.gnome.Screencast"
MAP["simplescreenrecorder"]="com.maartenbaert.Simplescreenrecorder"
MAP["virtualbox"]="org.virtualbox.VirtualBox"
MAP["TeamViewer"]="com.teamviewer.TeamViewer"
MAP["teamviewer"]="com.teamviewer.TeamViewer"
MAP["aseprite"]="com.aseprite.Aseprite"
MAP["inkscape"]="org.inkscape.Inkscape"

# --------------------------------------------------------------------------- #
# HELPERS
# --------------------------------------------------------------------------- #
log()  { echo "[INFO]  $*"; }
warn() { echo "[WARN]  $*" >&2; }
ok()   { echo "[OK]    $*"; }
skip() { $VERBOSE && echo "[SKIP]  $*"; }

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Options:
  --dry-run        แสดงผลโดยไม่สร้างไฟล์จริง
  --verbose        แสดงทุก symlink ที่สร้างและที่ข้าม
  --base DIR       path ของ icons/ directory
                   (default: ./icons เทียบกับตำแหน่ง script)
  --help           แสดง help นี้

ตัวอย่าง:
  ./wildfire-symlink-rdns.sh
  ./wildfire-symlink-rdns.sh --dry-run --verbose
  ./wildfire-symlink-rdns.sh --base /home/xenatt/git/wildfire/icons
EOF
    exit 0
}

# --------------------------------------------------------------------------- #
# PARSE ARGS
# --------------------------------------------------------------------------- #
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)  DRY_RUN=true; shift ;;
        --verbose)  VERBOSE=true; shift ;;
        --base)     ICONS_BASE="$2"; shift 2 ;;
        --help|-h)  usage ;;
        *) warn "unknown option: $1"; shift ;;
    esac
done

# --------------------------------------------------------------------------- #
# VALIDATE
# --------------------------------------------------------------------------- #
if [[ ! -d "$ICONS_BASE" ]]; then
    echo "ERROR: ไม่พบ icons directory: $ICONS_BASE"
    echo "ระบุด้วย --base PATH หรือรัน script จาก root ของ wildfire repo"
    exit 1
fi

$DRY_RUN && log "=== DRY RUN MODE — ไม่มีการเปลี่ยนแปลงไฟล์จริง ==="
log "Icons base: $ICONS_BASE"

# --------------------------------------------------------------------------- #
# PROCESS FUNCTION
# สแกนทุก Context dir (Apps, Places, Mimes, Devices, Status, Emblems, Categories)
# ภายในแต่ละ theme
# --------------------------------------------------------------------------- #
TOTAL_CREATED=0
TOTAL_SKIPPED=0
TOTAL_THEMES=0

process_theme() {
    local theme_dir="$1"
    local theme_name
    theme_name="$(basename "$theme_dir")"

    # หา context dirs ที่มีอยู่จริง
    local context_dirs=()
    for ctx in Apps Places Mimes Devices Status Emblems Categories; do
        [[ -d "$theme_dir/$ctx" ]] && context_dirs+=("$theme_dir/$ctx")
    done

    if [[ ${#context_dirs[@]} -eq 0 ]]; then
        skip "theme $theme_name ไม่มี context directories"
        return
    fi

    TOTAL_THEMES=$(( TOTAL_THEMES + 1 ))
    log "── Theme: $theme_name"

    local ctx_dir
    for ctx_dir in "${context_dirs[@]}"; do
        local ctx_name
        ctx_name="$(basename "$ctx_dir")"

        local old_name rdns_name
        for old_name in "${!MAP[@]}"; do
            rdns_name="${MAP[$old_name]}"

            # หาไฟล์ต้นทาง
            local src_file=""
            for ext in svg png xpm; do
                local candidate="$ctx_dir/${old_name}.${ext}"
                if [[ -f "$candidate" && ! -L "$candidate" ]]; then
                    src_file="$candidate"
                    break
                fi
            done
            [[ -z "$src_file" ]] && continue

            local ext="${src_file##*.}"
            local link_path="$ctx_dir/${rdns_name}.${ext}"

            # ข้ามถ้ามีอยู่แล้ว (ไฟล์จริง หรือ symlink)
            if [[ -e "$link_path" || -L "$link_path" ]]; then
                skip "$theme_name/$ctx_name/${rdns_name}.${ext} (มีอยู่แล้ว)"
                TOTAL_SKIPPED=$(( TOTAL_SKIPPED + 1 ))
                continue
            fi

            local rel_src
            rel_src="$(basename "$src_file")"

            if $DRY_RUN; then
                echo "[DRY]   $theme_name/$ctx_name/${rdns_name}.${ext}  →  ${rel_src}"
            else
                ln -s "$rel_src" "$link_path"
                ok "$theme_name/$ctx_name/${rdns_name}.${ext}  →  ${rel_src}"
            fi
            TOTAL_CREATED=$(( TOTAL_CREATED + 1 ))
        done
    done
}

# --------------------------------------------------------------------------- #
# RUN: ค้นหา theme dirs (มี index.theme)
# --------------------------------------------------------------------------- #
mapfile -t THEME_DIRS < <(
    find "$ICONS_BASE" -maxdepth 1 -mindepth 1 -type d \
      -exec test -f "{}/index.theme" \; -print | sort
)

if [[ ${#THEME_DIRS[@]} -eq 0 ]]; then
    echo "ERROR: ไม่พบ theme directory (ต้องมี index.theme) ใน $ICONS_BASE"
    exit 1
fi

log "พบ ${#THEME_DIRS[@]} themes"

for tdir in "${THEME_DIRS[@]}"; do
    process_theme "$tdir"
done

# --------------------------------------------------------------------------- #
# UPDATE ICON CACHE
# --------------------------------------------------------------------------- #
if ! $DRY_RUN && [[ $TOTAL_CREATED -gt 0 ]]; then
    log "อัปเดต icon cache..."
    for tdir in "${THEME_DIRS[@]}"; do
        if command -v gtk-update-icon-cache &>/dev/null; then
            gtk-update-icon-cache -f -t "$tdir" 2>/dev/null \
              && log "cache updated: $(basename "$tdir")"
        fi
    done
fi

# --------------------------------------------------------------------------- #
# SUMMARY
# --------------------------------------------------------------------------- #
echo ""
echo "══════════════════════════════"
echo "  สรุปผล"
echo "══════════════════════════════"
printf "  Themes ที่ scan : %d\n" "$TOTAL_THEMES"
printf "  สร้าง symlink  : %d\n" "$TOTAL_CREATED"
printf "  ข้าม (มีอยู่แล้ว): %d\n" "$TOTAL_SKIPPED"
$DRY_RUN && echo "  [DRY RUN — ไม่มีการเปลี่ยนแปลงจริง]"
echo "══════════════════════════════"
