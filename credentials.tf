resource "linode_sshkey" "MacBookAir" {
  label = "MacBook Air"
  ssh_key = chomp(file("~/.ssh/github.pub"))
}
