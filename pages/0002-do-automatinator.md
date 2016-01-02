## Itch of the Week: Archiving and Restoring Digitalocean Droplets Painlessly
### <i>a.k.a. Going Full Nomad With do-automatinator</i>
<small>Jan 2, 2016</small>

In the previous (first, actually) post I have promised deep stuff. It is coming, just not yet.

The motto used (*Release early, release often*) was popularized by Eric S. Raymond in his 1997 essay.
The text also mentions other "lessons", such as "Every good work of software starts by scratching a developer's personal itch." (- [The Cathedral and the Bazaar](https://en.wikipedia.org/wiki/The_Cathedral_and_the_Bazaar))

### The Backstory
* Digitalocean offers cheap VPS service
* You only have to pay for the hours your machines "exist", so you can go even cheaper if you are not running (permanent) services, but using the machines for development, etc.
* You don't have to pay when the machines are "destroyed"
* You can save the machines
* You can only save machines that are powered-off

### The Itch
* You can't "just" shutdown, snapshot and destroy a machine with a single click of a button or a command

### The Scratch
[do-automatinator](https://github.com/bessbd/do-automatinator) is a command-line tool to shut down, snapshot and destroy a machine at Digitalocean. (And to do the reverse, too)

### Some Tech Stuff
#### Setting Your Token
```bash
coffee app.coffee settoken <your digitalocean token>
```
(You only have to do this once)
#### Shutting Down, Snapshotting and Destroying a Machine
```bash
coffee app.coffee save <machine name>
```
#### Creating a Machine from a Snapshot (aka Restoring a Machine)
```bash
coffee app.coffee restore <machine name>
```
### The Conclusion
This way, I (and anyone using the tool) can create a machine, set it up and only pay for the hours the machine is actually in use. (As a bonus, even backups are created, for free(!))
