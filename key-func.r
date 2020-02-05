akey <- function(..., begin.index =NULL, end.index =NULL, ke = NULL){
  if(is.null(ke)){ke = key}
  out = paste0(...)
  out = paste0(out,"?")
  
  paste.vec =NULL
  if(!is.null(end.index)){ paste.vec = c(paste.vec, paste0("endIndex=",end.index))}
  
  if(!is.null(begin.index)){ paste.vec = c(paste.vec, paste0("beginIndex=",begin.index))}
  
  paste.vec = c(paste.vec, paste0("api_key=", ke))
  out = paste0(out, paste0(paste.vec, collapse = "&"))
  return(out)
}

diskey <- function(..., begin.index =NULL, end.index =NULL, ke = NULL){
  #key for display, (not showing the api keys)
  if(is.null(ke)){ke = key}
  out = paste0(...)
  out = paste0(out,"?")
  
  paste.vec =NULL
  if(!is.null(end.index)){ paste.vec = c(paste.vec, paste0("endIndex=",end.index))}
  
  if(!is.null(begin.index)){ paste.vec = c(paste.vec, paste0("beginIndex=",begin.index))}
  paste.vec = c(paste.vec, paste0("api_key=", "cannot_disclose"))
  out = paste0(out, paste0(paste.vec, collapse = "&"))
  return(out)
}

# akey <- function(..., ke = NULL){
#   if(is.null(ke)){
#     ke = key
#   }
#   st = paste0(...)
#   return(paste0(st, "?api_key=", ke))
# }