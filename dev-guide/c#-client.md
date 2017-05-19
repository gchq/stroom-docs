# Maintaining the C# Stroom client

First install the .NET libraries and runtime, [Mono](http://www.mono-project.com/):

```bash
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb http://download.mono-project.com/repo/debian wheezy main" | sudo tee /etc/apt/sources.list.d/mono-xamarin.list
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install mono-complete
```

Then install the IDE and plugins, [MonoDevelop](http://www.monodevelop.com/)

```bash
sudo apt-get install monodevelop
sudo apt-get install monodevelop-nunit
sudo apt-get install monodevelop-versioncontrol
```

You can then load the solution file (*.sln) using MonoDevelop.