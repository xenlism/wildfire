%global srcname wildfire
%global project xenlism

Name:           %{project}-%{srcname}-icon-theme
Version:        2018.05beta2
Release:        1%{?dist}
Summary:        Minimalism And Realism Mix and match, Meego And iOS icon Style.

License:        GPLv3+
URL:            https://%{project}.github.io/%{srcname}
Source0:        https://github.com/%{project}/%{srcname}/archive/%{version}.tar.gz#/%{srcname}-%{version}.tar.gz


BuildArch:      noarch
BuildRequires:  coreutils


%description
Minimalism And Realism Mix and match, macOS icon Style
Xenlism is Computer Graphic And Programming project to make something better.
Xenlism Wildfire is icon theme for *nix desktop environment.
inspired by Nokia's meego and Apple iOS icon.
best for gnome and (Maybe) unity, mate, cinnamon.

%prep
%setup -qn%{srcname}-%{version}
# W: hidden-file-or-dir, E: zero-length
find icons -name '.*' -print -delete
# W: spurious-executable-perm
#chmod -x Screenshot/*.png
# W: dangling-relative-symlink
rm icons/Xenlism-Wildfire/Mimes/text-x-lyx.svg

%build
# nothing

%install
# copied from upstream install script
install -dm755 %{buildroot}%{_datadir}
cp -pr icons %{buildroot}%{_datadir}
find  %{buildroot}%{_datadir}/icons -type d -exec chmod 755 '{}' \;
find  %{buildroot}%{_datadir}/icons -type f -exec chmod 644 '{}' \;



%post
/bin/touch --no-create %{_datadir}/icons/Xenlism-Wildfire* &>/dev/null || :

%postun
if [ $1 -eq 0 ] ; then
    /bin/touch --no-create %{_datadir}/icons/Xenlism-Wildfire* &>/dev/null
    /usr/bin/gtk-update-icon-cache %{_datadir}/icons/Xenlism-Wildfire* &>/dev/null || :
fi

%posttrans
/usr/bin/gtk-update-icon-cache %{_datadir}/icons/Xenlism-Wildfire* &>/dev/null || :


%files
%license LICENSE.md
%doc README.md
%{_datadir}/icons/Xenlism-Wildfire/
%{_datadir}/icons/Xenlism-Wildfire-MonDay/
%{_datadir}/icons/Xenlism-Wildfire-TuesDay/
%{_datadir}/icons/Xenlism-Wildfire-WednesDay/
%{_datadir}/icons/Xenlism-Wildfire-ThursDay/
%{_datadir}/icons/Xenlism-Wildfire-FriDay/
%{_datadir}/icons/Xenlism-Wildfire-SaturDay/
%{_datadir}/icons/Xenlism-Wildfire-SunDay/
%{_datadir}/icons/Xenlism-Wildfire-MonDay-Night/
%{_datadir}/icons/Xenlism-Wildfire-TuesDay-Night/
%{_datadir}/icons/Xenlism-Wildfire-WednesDay-Night/
%{_datadir}/icons/Xenlism-Wildfire-ThursDay-Night/
%{_datadir}/icons/Xenlism-Wildfire-FriDay-Night/
%{_datadir}/icons/Xenlism-Wildfire-SaturDay-Night/
%{_datadir}/icons/Xenlism-Wildfire-SunDay-Night/
#%%doc Screenshot/



%changelog
* Mon May 14 2018 Nattapong Pullkhow <ixenatt@gmail.com> - 2018.05.02
- Init for fedora




