# Skript für Folge 1

Hallo und herzlich willkommen zur einer neuen Videoserie von thenativeweb in Zusammenarbeit mit Docker.

---

In der heutigen ersten Folge von "Einführung in Docker" geht es um die Grundkonzepte rund um Docker und Container.

Nach dieser Folge weißt Du bereits die wichtigsten Begriffe und weißt, wo die Vorteile und Einsatzgebiete von Docker liegen.

---

Mein Name ist Stefan Scherer und ich arbeite seit vielen Jahren als Software Engineer.

Seit Mitte 2014 habe ich die ersten Erfahrungen mit Docker gemacht. Nach ersten Gehversuchen hat mich dieses Thema mehr fasziniert und ich wurde in der Community aktiv und habe auf Meetups und Konferenzen Vorträge gehalten.

Durch meine Community Aktivitäten wurde ich Docker Captain und Microsoft MVP.

Für den Raspberry Pi haben wir in einem kleinen Team die Verwendung von Docker vereinfacht, woraus sehr schnell eine eigene Distribution HypriotOS entstanden ist.

Mich begeistert auch das große Spektrum von Docker und so blogge ich gerne auch über Windows Container.

Seit 2019 arbeite ich für Docker und bin dort im Docker Desktop Team tätig. Ich betreue auch unsere gesamten CI Infrastrukturen mit allen unterstützen Plattformen.

Ich bin weiterhin der Community treu und stehe für Fragen zur Verfügung. Mich erreicht man am besten über Twitter oder GitHub.

---

Zu Beginn jeder Folge gebe ich Dir einen kurzen Überblick, was wir durchnehmen werden.

In dieser ersten Folge fangen wir ganz am Anfang an. Heute werden wir noch nichts auf deinem Rechner installieren, du brauchst also noch nichts vorbereiten.

Aber wir werden heute dennoch ein paar praktische Beispiele gegen Ende machen.

Zunächst erkläre ich, warum man sich mit Containern beschäftigen sollte und was den Reiz ausmacht, Anwendungen in Containern laufen zu lassen.

Wir werfen einen kleinen Blick auf virtuelle Maschinen und wie sich Container im Vergleich dazu unterscheiden.

Ich zeige des weiteren, was Docker ist und warum es quasi eine Revolution ausgelöst hat und Container so populär gemacht hat.

Du wirst auch erfahren wie Docker funktioniert und wie man Anwendungen auf beliebigen Rechnern leicht verteilen und starten kann. Anhand eines typischen Ablaufs stelle ich Dir auch die vier wichtigsten Begriffe vor, damit du sie dann gut einordnen kannst.

Am Ende dieser Folge weißt Du wirklich die Grundlagen rund um Container und Docker.

---

Warum solltest du dich also mit Containern auseinandersetzen?

Ich möchte dir das anhand einer Beispielapplikation zeigen.

---

Schauen wir uns also einmal an, wie eine Applikation auf einem Server betrieben wird.

Zunächst muss die Anwendung installiert werden, diese benötigt üblicherweise noch Abhängigkeiten, etwa Bibliotheken oder eine Laufzeitumgebung.

Des weiteren wird die Anwendung in einer bestimmten Form konfiguriert, damit sie den konkreten Anforderungen genüge tut.

In diesem Beispiel reicht die Rechenkapazität noch aus, daher wird eine zweite Applikation, die die gleichen Bibliotheken benötigt, mit auf dem Server installiert. Alles läuft wunderbar.

Was passiert aber nun, wenn es eine neue Version dieser zweiten Anwendung gibt?

Früher hat man vielleicht die Anwendung gestoppt und man hat sich dann an das Update gemacht. Womöglich müssen neue Laufzeitumgebungen eingespielt werden. Erst nach diesem Update merkte man, ob die neue Version auf dem Rechner funktionert order nicht. Im Falle eines Problems ist es dann sehr schwer, wieder auf die vorherige Version zurückzukehren.

Später kommt vielleicht mal ein größeres Update der zweiten Anwendung heraus und dort werden neue Bibliotheken verwendet, die inkompatibel sind.
Für Anwendung 2 ist das ja in Ordnung, aber das ergibt nun ein Problem bei der ersten Anwendung. Die wurde noch nicht an die neue Bibliothek angepasst, das Update kommt erst später.

Nun hat man einen Konflikt, da man auf einem Rechner Abhängigkeiten zwischen den Anwendungen geschaffen hat.

Was man erreichen möchte ist, dass Anwendungen leichter auszutauschen sind und sich nicht beeinflussen. Hier kommt nun die Idee von Containern ins Spiel.

Ein Container ist keine harte Grenze wie ein eigener Rechner, eher eine logische Grenze, es ist wie ein Zaun um die Applikation.

---

Innerhalb dieser Grenze befindet sich die Anwendung mit allem, was sie braucht, um ausgeführt zu werden. Man trennt also das Betriebssystem von der Anwendung logisch ab.

---

Mit diesem Konzept wird jede Anwendung in einem eigenen Container betrieben. Das Update von Anwendung 2 verursacht nun keine Probleme bei den anderen Anwendungen mehr.
Ebenso können Anwendungen sauber wieder entfernt werden, es bleibt wirklich nichts auf dem Server übrig.

Mit Containern wird es also sehr leicht, zwei verschiedene Versionen der Applikation auf dem selben Rechner zu betreiben und schnell von der alten auf die neue Version zu wechseln. Und ebenso auch wieder zurück zur alten Version, falls das Update doch mal Probleme macht.

---

Container haben ja auch den Transport von Gütern vereinfacht. Durch die Standardgrößen können sie leicht auf Schiffen, LKWs oder Zügen transportiert werden.

Auch in der Software sind solche Anwendungs-Container standardisiert.

So wird jeder Anwendungs-Container auf die gleiche Art gestartet und zwar mit einem präzisem Ausgangszustand, den die Entwicklung festgelegt hat.

Da ja alle Abhängigkeiten vorhanden sind ist klar, wie sich die Anwendung beim Start verhält.

Und dies identisch ob man den Container nun lokal auf einem Entwickler-Rechner oder auf einem Server beim Kunden starten wird.

Es gibt weitere definierte Schnittstellen, etwas wie Netzwerk-Ports zum Host oder zu anderen Containern benutzt werden können.

Jeder Container erhält seine eigene IP Adresse und einen eigenen Hostnamen. Für die Anwendung im Container fühlt es sich so an, als laufe sie auf einem eigenen Rechner.

Eine weitere standardisierte Schnittstelle sind Volumes, damit man Dateien und Verzeichnisse dauerhaft speichern kann. Wir werden das in späteren Folgen genauer betrachten.

---

Schauen wir uns im folgenden Bild auch den Unterschied zwischen virtuellen Maschinen und Containern an.

Vielleicht hast du dir in dem Beispiel vorhin gedacht, man hätte die Anwendungen ja in virtuelle Maschinen packen können. Richtig, das sähe dann wie im Bild auf der linken Seite aus.

Es werden zwei VMs gestartet, die jede für sich ein Gast-Betriebssystem benötigen. Das muss gebootet werden, und danach kann die jeweilige Anwendung gestartet werden.

Auf dem Server wird ein Hypervisor benötigt, der die virtuellen Maschinen starten und ihnen Resourcen wie Plattenplatz und Arbeitsspeicher zuteilt.

Im Gegensatz dazu sind Container viel leichtgewichtiger. Hier im Bild rechts zu sehen laufen Container direkt im Betriebssystem des Servers. Der gedachte "Zaun" für ein eigenes Dateisystem mit den Programmdateien und den Laufzeitbibliotheken wird mit dem Betriebsystemmitteln erreicht.

Docker wird auf dem Server installiert und vereinfacht die Steuerung von Containern.

Zum Starten der Anwendungen muss kein Gast-Betriebssystem gebootet werden, sondern es wird gleich die Anwendung gestartet. Der Start ist meist in wenigen Sekunden erfolgt, viel schneller als man eine virtuelle Maschine booten könnte.

Container nutzen den Kernel des Betriebssystems des Servers, im Kernel gibt es sogenannte Namespaces und andere Mechanismen, um diese logische Grenze eines Containers zu realisieren.

So sieht man etwa auf dem Server alle Prozesse aus allen Containern. In einem Container sieht man jedoch nur die Prozesse, die innerhalb dieses Containers laufen.

Ebenso wird mit dem Dateisystem verfahren, innerhalb des Containers sieht man nur das gewünschte Dateisystem, das für die Anwendung benötigt wird.

---

Nachdem wir nun schon ein paar Details zu Linux-Containern kennengelernt haben, stellt sich wohl die Frage, was Docker nun genau ist.

---

Docker wurde im Jahr 2013 auf einer Python-Konferenz dem Publikum vorgestellt. Du kannst das Video auf Youtube finden, wenn du nach Future of Linux Containers sucht.

Die damalige Firma dotCloud hat die immer wiederkehrenden Probleme beim Betrieb von Anwendungen auf Servern in der Cloud vereinfacht. In dem Vortrag wurde ein kleines Kommandozeilen-Tool namens "Docker" live gezeigt, mit der die ganzen Mechanismen die es in Linux gibt zur einem simplen Befehlssatz stark vereinfacht.

docker run image

Sie haben daraufhin in vielen Meetups das Interesse in der Community geweckt und so wurde an dem Open Source Projekt schnell weiter gearbeitet.

Durch das simple Konzept wurde mit Docker das Thema Container sehr populär und zu einem Quasi-Standard in der Softwarebranche geworden.

Aus der Firma dotCloud wurde später die Docker Inc. - mit Sitz im Silicon Valley, die heute noch das Tool Docker weiter pflegt.

Zwischenzeitlich entstand eine Enterprise Plattform, die Ende 2019 an Mirantis verkauft wurde. Aktuell fokusiert sich die Docker Inc. wieder auf Entwicklertools und Dienste, auf die ich noch eingehen werde.

---

Docker besteht aus mehreren Tools.

Für die Entwicklung auf macOS und Windows Betriebssystemen steht mit Docker Desktop ein Werkzeug zur Verfügung, um lokal Container laufen zu lassen und auch selbst Anwendungen in Container zu packen.

Bei Containern handelt es sich zu 99% um Linux-Container. Bei Docker Desktop muss also noch mithilfe einer Linux-VM überhaupt die Basis geschaffen werden, auf Mac und Windows Linux-Container zu betreiben. Docker Desktop bringt alles mit und nutzt die betriebssystem-eigenen Hypervisor.

Mit dem Docker Hub - der wohl bekanntesten Container-Registry - und den darin enthaltenen offiziellen Images für verschiedene Programmiersprachen und Anwendungen konnte überhaupt diese Revolution entstehen. Denn über den Docker Hub ist es möglich, Anwendungen zwischen verschiedenen Entwicklern und Rechnern auszutauschen.

Dann ist da die Docker-Engine, die wir in dem vorherigen Bild schon einmal kurz gesehen haben. Das ist ein Dienst, der auf einem Linux-Rechner läuft, oder im Falle von Mac und Windows in einer Linux-VM. Dieser kann per API und dem Docker CLI angesprochen werden und steuert den Start von Containern, das Herunter- und Hochladen von Container Images und so weiter.

Von Docker gibt es auch noch weitere Tools, die wir in einer späteren Folge genauer betrachten werden. Für heute reicht dieser kleine Überblick aus.

---

Ich habe schon kurz angefangen zu erklären, was die Docker Engine macht. In den folgenen Minuten möchte ich dir zeigen, wie Docker nun funktioniert, dann wird es klar, was den Reiz daran ausmacht.

---

Entlang des Beispiels wirst du auch mit folgenden vier Begriffen vertraut.

Ich habe sie auf dieser Folie zusammengefasst, du kannst diese Folie quasi als Merker hernehmen, was mit jedem Begriff gemeint ist.

Fangen wir von vorne an. Da ist zunächst das sogenannte Dockerfile.

Ein Dockerfile ist eine Textdatei, in die du quasi die Bauanleitung eingibst, um deine Applikation zu installieren. Docker kann diese Datei interpretieren und erstellt damit ein Image - ein Abbild deiner fertigen Applikation. Wir sehen gleich ein Beispiel, wie so ein Dockerfile aussieht.

Das Image enthält das Dateisystem mit deiner Anwendung und allen benötigten Dateien und Abhängigkeiten. Ein Image wird auch manchmal Container-Image oder Docker-Image genannt.

Eine wichtige Rolle spielt auch eine Registry. Eine Registry ist eine zentrale Bibliothek, um fertig gebaute Images zu speichern und wieder zu laden. Der Docker Hub genau so eine Registry, nur eben mit einem bekannteren Namen. Man kann auch eigene Registries betreiben oder eine von anderen Cloudanbietern nutzen.

Als viertes gibt es noch den Begriff Container. Wenn wir von einem Container sprechen, meinen wir eine laufende Applikation, die von einem vorbereiteten Image gestartet wird.

Ich möchte dir diese vier Begriffe noch einmal anhand eines typischen Ablaufs zeigen, wie man eine Anwendung auf seinem eigenen Rechner erstellt, die dann auf einem anderen Linux-Server betrieben werden soll.

---

Auf der linken Seite ist unser eigener Recher, auf der rechten Seite siehst du den Server, auf dem wir später die Anwendungen laufen lassen wollen.

Es geht los mit einem Dockerfile.

---

Wir verwenden das Dockerfile, um mit dem Befehl "docker build" daraus ein Image zu erstellen. Auch das Image liegt dann noch lokal auf dem eigenen Rechner.

Das Dockerfile mag Befehle enthalten wie zum Beispiel die Installation von benötigten Laufzeitumgebungen oder Paketen, ebenso denkbar ist der Aufruf von Compileren, um überhaupt erst ein lauffähiges Programm aus dem Quellcode zu erstellen.

Ein Dockerfile berreichert quasi die eigenen Quellcodes und wird auch als solche mit in die Sourcecodeverwaltung aufgenommen. So hat man auch die Bauanleitung versioniert.

Wie bekommen wir nun das Image auf den anderen Rechner?

---

Hierzu gibt es den Befehl "docker push", um ein Image in eine Registry hochzuladen. Image erhalten Namen und sogenannte Tags, die zum Beispiel eine Versionsnummer enthalten. Dadurch kann man auch mehrere Versionen in der Registry aufheben.

---

Auf dem Server ist auch Docker installiert. Mit dem Befehl "docker pull" können Images nun aus der Registry auf den Server heruntergeladen werden.

In dem Image enthalten sind ja alle benötigten Dateien und Verzeichnisse für die jeweilige Anwendung.

---

Zu guter letzt gibt es mit "docker run" noch den Befehl zum Starten eines Containers. Ein Container startet mit dem Dateisystemabbild des Image und unsere Anwendung startet auf dem Server.

Das ist im Prinzip schon alles, was du wissen musst, um Container und Docker zu verstehen.

Die große Popularität von Docker entsteht durch diese wenigen Befehle, die das Erstellen von Images erleichtert hat.

Große Bedeutung hat auch die Registry, der Docker Hub, in dem mit einer Vielzahl von offiziellen Images auch qualitativ hochwertige Images zur Verfügung stehen.

Denn das machen auch Container aus, niemand muss von Null anfangen, sondern baut auf bereits vorhandenen Images im Docker Hub auf, um eigene Anwendungs-Images zu bauen.

In der nächsten Folie zeige ich dir ein Dockerfile, damit du eine Vorstellung bekommst, wie so eine Bauanleitung aussieht.

---

Ein Dockerfile ist eine Textdatei, quasi wie jeder andere Quellcode auch.

Das hier gezeigte Dockerfile packt den Apache Webserver in ein Image, damit wir zum Beispiel einen eigenen Webserver in einem Container starten können.

Das Dockerfile beschreibt nun Zeile für Zeile, was zu tun ist, damit wir das ausführbare Programm und alle benötigten Abhängigkeiten installieren.

Es gibt mehrere Befehle, die von Docker interpretiert werden, wenn aus dem Dockerfile ein Image gebaut wird.

Am Anfang jedes Dockerfiles steht eine Zeile mit "FROM".

Mit FROM wird mitgeteilt, mit welchem Basis-Image man starten möchte. Wie ich schon sagte, muss man nicht von Null anfangen. Man kann auf eines der vielen offiziellen Images zurückgreifen, etwa einer gewünschten Linux-Distribution.

In diesem Beispiel verwenden wir das debian Basisimage und schreiben daher "FROM debian".

Woher bekommt man die Namen der offiziellen Images?

Im Docker Hub kann man nach Images schauen und dort sind auch kurze Beschreibungen zu finden. Schauen wir daher kurz auf den Docker Hub, um mehr über das Debian Image zu erfahren.

---
switch to browser
open docker hub
search debian
show tags, readme, ...
show other official images
---

Die nächsten Zeilen beginnen immer mit "RUN". Dies bedeutet, dass der nachfolgende Befehl beim Bauen des Image ausgeführt werden soll.

Da wir Debian als Basisimage nutzen, wird mit dem Befehl apt-get der Paketmanager von Debian aufgerufen. Wir aktualisieren zuerst die Paketverwaltung und im nächsten Befehl installieren wir das Paket mit dem Namen apache2.

Der nächste Befehl erstellt noch ein Verzeichnis in dem Image, weil es später zur Laufzeit benötigt wird.

Nun kommt ein neuer Befehl: EXPOSE

Damit teilen wir Docker mit, dass dieses Image den Netzwerkport 80 verwendet. Hier handelt es sich nur um eine Information, die aber später aus dem Image auslesbar ist und dem Benutzer des Image hilft zu verstehen, auf welchem Port unser Webserver lauschen wird.

Am Ende eines Dockerfile befindet sich häufig der CMD Befehl.
Wie man hier sieht, definiert es den Befehl, der beim Start eines Container aufgerufen werden soll.

Also definieren wir Entwickler bereits, wie unser Container später einmal zu starten ist.

Es gibt natürlich noch weitere Befehle, die du in weiteren Folgen kennenlernen wirst.

Aber für unser Beispiel mit dem Apache Webserver reicht dieses Dockerfile bereits aus.

---

Wenn wir mit "docker build" nun ein Image bauen, wird das Dockerfile Zeile für Zeile interpretiert.

Für jede Zeile wird ein kleines Delta im Dateisystem erstellt - ein sogenannter Layer, oder Image Layer.

So wird bei FROM debian zunächst das debian Image als Basis herangezogen mit allen darin enthaltenen Dateien.

Der erste RUN Befehl aktualisiert die Paketlisten, das lädt üblicherweise neue Dateien aus dem Internet und legt sie im Dateisystem ab.

Ab jetzt hat man Zugriff auf die aktuellen Pakete von Debian. Am Ende des RUN Befehls wird dieser Layer geschlossen und lokal abgelegt.

Der zweite RUN Befehl installiert nun den Apache2 Webserver mit allen benötigten Paketen.

Ich habe hier die ungefähren Größen in jeden Layer geschrieben, der lokal benötigt wird.

Auch hier wird der Layer abgeschlossen, jeder RUN Befehl schreibt nichts in vorherige Layer.

So geht es nun Befehl für Befehl weiter, zu EXPOSE und CMD, die nur Metadaten anlegen.

Am Ende des Bauvorgangs ist nun das fertige Image lokal abgelegt.

---

Schauen wir uns im folgenden Bild auch noch einmal den Unterschied zwischen einem Image und einem Container an. Das war für mich am Anfang die größte Hürde und verursachte bei mir immer wieder Verwirrung.

Wenn wir nun einen Container starten, geben wir beim Start den Namen eines Image an.

In diesem Fall wäre das unser Apache Image.

Ein laufender Container erhält immer noch einen schreibbaren Layer für die Laufzeit zugeteilt.

So kann der Apache Webserver Dateien lesen und schreiben, es werden ja etwa lck Dateien oder Logdateien geschrieben.

Diese landen aber nicht im Image, dies ist gegen Änderungen geschützt.

So hat jeder Container sein eigenes Dateisystem, in dem die lck Datei und Logdateien unabhängig von anderen Containern geschrieben werden können.

Deshalb ist es möglich, auch mehrere Instanzen auf einem Rechner zu betreiben.

Der Unterschied zwischen Image und Container ist also:

Ein Image ist das statische Abbild des Dateisystems, also quasi ein Foto (im englischen Image) von, wie es zum Startzeitpunkt aussehen soll.

Ein Container startet eine Kopie des Image, und die Prozesse im Container haben die Möglichkeit, während der Laufzeit Änderungen im Dateisystem vorzunehmen.

Probieren wir das soeben gelernte in der Praxis aus.

---

Ich habe ja gesagt, dass wir heute noch nichts lokal auf deinem Rechner installieren.

Stattdessen nutzen wir einen weiteren Service von Docker - Play with Docker - um die ersten Schritte einfach im Browser durchzuführen.

Was wir in den nächsten Minuten machen werden, ist, nochmal zum Docker Hub zu gehen und dort einen Account zu erstellen.

Keine Angst, das ist kostenlos und erfordert auch keine Kreditkarte.

Es dient einfach dazu, den Dienst Play with Docker gegen Missbrauch zu schützen. Es wird für uns nämlich quasi eine kleine virtuelle Linux-Umgebung mit Docker bereitgestellt. Den Docker Hub Account werden wir auch in weiteren Folgen verwenden, um unsere Images dauerhaft abzulegen.

---
open docker hub
sign up, confirm email
---
open play with docker
sign in
create instance
---

Nachdem wir nun eine Play with Docker umgebung startet haben, haben wir ein Linux Terminal.

Für diese Videoserie gibt es auch Beispiele auf GitHub, die du nutzen kannst, damit du nicht alles vom Video abtippen musst.

Mit dem Befehl "git clone" laden wir uns die Beispiele in die Play with Docker Instanz herunter.

Im Ordner 01-grundkonzepte findest du das Dockerfile von der Folie weiter vorne.

Als nächstes schauen wir uns noch einmal das Dockerfile an.

---

Nun können wir das Image erstellen.

docker build -t apache2 .

---

Mit dem Befehl "docker images" können wir nachsehen, welche Images lokal heruntergeladen oder gebaut wurden.

Wie man sieht werden hier zwei Images aufgelistet, einmal das Basisimage debian und unser frisch gebautes apache2 image.

Nun starten wir einen Container

docker run -d -p 8080:80 apache2

Ich habe hier absichtlich unterschiedliche Ports zwischen Host und Container verwendet, um besser zu zeigen, welche für Host und welcher für den Container da ist.

Meine Eselsbrücke wie ich es mir merke ist, von links nach rechts geht man wie bei der Netzwerkstrecke vom Browser zum Host-Port zum Container-Port.

docker ps
docker kill
browser close oder quit

---

Und damit sind wir auch schon am Ende der ersten Folge.

Ich hoffe, ich konnte dir die Grundlagen von Docker näher bringen und dir einen Einstieg in die Thematik geben. Du kannst gerne noch etwas auf Play with Docker ausprobieren oder am Ende den Browser schließen.

In der nächsten Folge zeige ich dir wie man Docker auf deinem Rechner lokal installiert.

Dann hast du die Möglichkeit, das vorhin gezeigt Szenario - lokal bauen, hochladen auf den Docker Hub und dann Starten eines Containers zu üben.

Wenn du Fragen oder Anregungen hast, kannst du mich gerne auf Twitter kontaktieren oder du schreibst eine Mail an das Team von thenativeweb.

Tschüss bis zum nächsten Mal.
