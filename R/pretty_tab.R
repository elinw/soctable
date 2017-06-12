#' Print a crosstab nicely in PDF or HTML
#'
#' @param ctab crossstab object as produced by soctable::crosstab
#'
#' @keywords crosstab, print
#' @export

pretty_tab<-function(ctab){

    pander::pander(ctab$tab, keep.line.breaks = TRUE, justify = "right")

}
