#  File R/startup.utilities.R in package statnet.common, part of the Statnet suite
#  of packages for network analysis, http://statnet.org .
#
#  This software is distributed under the GPL-3 license.  It is free,
#  open source, and has the attribution requirements (GPL Section 7) at
#  http://statnet.org/attribution
#
#  Copyright 2007-2019 Statnet Commons
#######################################################################
## .who.loaded.me <- function(){
##   top.call <- sys.calls()[[1]] # Grab the top-level call.
##   top.fn <- as.character(top.call[[1]])
  
##   if(length(top.fn)!=1 || !(top.fn %in% c("library","require"))) return(NULL)

##   top.call <- match.call(get(as.character(top.call[[1]]),baseenv(),mode="function"),top.call) # Expand the arguments.
##   top.call <- as.list(top.call) # Turn the call into a list.
  
##   top.pkg <- top.call$package
  
##   if(!NVL(top.call$character.only,FALSE))
##     as.character(top.pkg)
##   else top.pkg
## }



#' Construct a "standard" startup message to be printed when the package is
#' loaded.
#' 
#' This function uses information returned by \code{\link{packageDescription}}
#' to construct a standard package startup message according to the policy of
#' the Statnet Project. To determine institutional affiliation, it uses a
#' lookup table that maps domain names to institutions. (E.g., *.uw.edu or
#' *.washington.edu maps to University of Washington.)
#' 
#' 
#' @param pkgname Name of the package whose information is used.
#' @param friends This argument is required, but will only be interpreted if
#' the Statnet Project policy makes use of "friendly" package information.
#' 
#' A character vector of names of packages whose attribution information
#' incorporates the attribution information of this package, or \code{TRUE}.
#' (This may, in the future, lead the package to suppress its own startup
#' message when loaded by a "friendly" package.)
#' 
#' If \code{TRUE}, the package considers all other packages "friendly". (This
#' may, in the future, lead the package to suppress its own startup message
#' when loaded by another package, but print it when loaded directly by the
#' user.)
#' @param nofriends This argument controls the startup message if the Statnet
#' Project policy does not make use of "friendly" package information but does
#' make use of whether or not the package is being loaded directly or as a
#' dependency.
#' 
#' If \code{TRUE}, the package is willing to suppress its startup message if
#' loaded as a dependency. If \code{FALSE}, it is not.
#' @return A string containing the startup message, to be passed to the
#' \code{\link{packageStartupMessage}} call or \code{NULL}, if policy
#' prescribes printing 's default startup message. (Thus, if
#' \code{statnetStartupMessage} returns \code{NULL}, the calling package should
#' not call \code{\link{packageStartupMessage}} at all.)
#' 
#' Note that arguments to \code{friends} and \code{nofriends} are merely
#' requests, to be interpreted (or ignored) by the \code{statnetStartupMessage}
#' according to the Statnet Project policy.
#' @seealso packageDescription
#' @keywords utilities
#' @examples
#' 
#' \dontrun{
#' .onAttach <- function(lib, pkg){
#'   sm <- statnetStartupMessage("ergm", friends=c("statnet","ergm.count","tergm"), nofriends=FALSE)
#'   if(!is.null(sm)) packageStartupMessage(sm)
#' }
#' }
#' @export
statnetStartupMessage <- function(pkgname, friends, nofriends){
  INST_MAP <- list(washington.edu="University of Washington",
                   uw.edu="University of Washington",
                   psu.edu="Penn State University",
                   uci.edu="University of California -- Irvine",
                   ucla.edu="University of California -- Los Angeles",
                   nyu.edu="New York University",
                   murdoch.edu.au="Murdoch University",
                   uow.edu.au="University of Wollongong"
                   ) 

  # Note that all options are ignored at this time, and the "wall of
  # text" is displayed unconditionally.
  
  desc <- utils::packageDescription(pkgname)
  pns <- eval(parse(text=desc$`Authors@R`))
  # The gsub is necessary because R CMD build can put line breaks in all sorts of fun places.
  pnnames <- gsub("[\n ]+", " ", format(pns, include=c("given","family")))

  # Find the institution associated with the domain of the specific e-mail message.
  find.inst <- function(email, map){
    if(is.null(email)) return(NULL)
    insts <- which(sapply(names(map),
                          function(inst){
                            instre <- paste('[@.]',gsub('.','\\.',inst,fixed=TRUE),sep='')
                            grepl(instre, email)
                          }
                          ))
    if(length(insts)) map[[insts]]
    else NULL
  }
  
  pninsts <- sapply(pns, function(pn) NVL(find.inst(pn$email, INST_MAP),""))

  authors <- sapply(pns, function(pn) "aut" %in% pn$role)

  pnlines <- ifelse(pninsts=="", pnnames, paste(pnnames,pninsts, sep=", "))
  
  copylist <- paste("Copyright (c) ",substr(desc$Date,1,4),", ",sep="")
  copylist <- paste(copylist, pnlines[authors][1],"\n",
                    paste(
                      paste(rep(" ",nchar(copylist)),collapse=""),
                      c(pnlines[authors][-1],if(sum(!authors)) "with contributions from",pnlines[!authors]),sep="",collapse="\n"),
                    sep="") 
     paste("\n",desc$Package,": version ", desc$Version, ', created on ', desc$Date, '\n',copylist,"\n",
          'Based on "statnet" project software (statnet.org).\n',
          'For license and citation information see statnet.org/attribution\n',
          'or type citation("',desc$Package,'").\n', sep="")
}


## statnetStartupMessage <- function(pkgname, quiet.if.dep=FALSE){
##   library(utils)
##   INST_MAP <- list(washington.edu="UW",
##                    uw.edu="UW",
##                    psu.edu="PSU",
##                    uci.edu="UCI",
##                    ucla.edu="UCLA",
##                    nyu.edu="NYU") 

##   if(quiet.if.dep){
##     top.pkg <- .who.loaded.me()
##     if(is.null(top.pkg) || top.pkg!=pkgname) return(NULL)
##   }
  
  
##   desc <- packageDescription(pkgname)
##   pns <- eval(parse(text=desc$`Authors@R`))
##   pnnames <- format(pns, include=c("given","family"))
##   pninsts <- sapply(pns, function(pn) NVL(INST_MAP[[gsub(".*?([^.@]+\\.[^.]{2,4})$","\\1",NVL(pn$email,""))]],""))

##   authors <- sapply(pns, function(pn) "aut" %in% pn$role)
##   autlines <- ifelse(pninsts[authors]=="", pnnames[authors], paste(pnnames[authors]," (",pninsts[authors],")",sep=""))
##   autline <- paste.and(autlines)
##   ctblines <- pnnames[!authors]
##   ctbline <- paste.and(ctblines)

##   mystrwrap <- function(...) paste(strwrap(...),collapse="\n")

##   m <- mystrwrap(paste(desc$Package, ' ', desc$Version, " by ", autline, if(length(ctblines)) paste(", with contributions from ", ctbline) else "", ".", sep=""))
##   paste('', m,mystrwrap(paste('Part of the Statnet suite (statnet.org).  For citation information, type citation("',desc$Package,'").',sep="")),collapse="\n",sep="\n")

## }
