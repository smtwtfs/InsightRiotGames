color.gradient <- function(x, colors=c("red","yellow","green"), colsteps=100) {
  return( colorRampPalette(colors) (colsteps) [ findInterval(x, seq(min(x),max(x), length.out=colsteps)) ] )
}

col.b <- function(numbers){
  color.gradient(1:numbers, c("#DCEDC8","#42b3d5","#1A237E"), colsteps = 100)
}

col.r <- function(numbers){
  color.gradient(1:numbers, c("#FEEB65","#E4521B","#4D342F"), colsteps = 100)
}

col.p <- function(numbers){
  color.gradient(1:numbers, c("#FFECB3","#E85285","#6A1B85"), colsteps = 100)
}
