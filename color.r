color.gradient <- function(x, colors=c("red","yellow","green"), colsteps=100) {
  return( colorRampPalette(colors) (colsteps) [ findInterval(x, seq(min(x),max(x), length.out=colsteps)) ] )
}

col.b <- function(numbers){
  color.gradient(1:numbers, c("#DCEDC8","#42b3d5","#1A237E"), colsteps = 100)
}

