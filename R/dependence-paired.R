#' Build covariance structures for genuinely paired or repeated effects
#'
#' @param effects Effect data containing `vi`.
#' @param pair_id Identifier for dependent observations.
#' @param r Correlation scalar, vector, or matrix.
#' @param structure `"paired"`, `"compound"`, or `"user"`.
#' @param user_V User-supplied covariance matrix for `structure="user"`.
#' @return An `apm_vcov` matrix.
#' @export
#' @examples
#' es <- apm_effect_size(wheat_paired_blocks,"lnRR",design="paired",m_t=mean_t,sd_t=sd_t,n_t=n_pairs,m_c=mean_c,sd_c=sd_c,n_c=n_pairs,r=r_tc)
#' apm_pair_vcov(es, pair_id=study_id, r=.6)
#' apm_pair_vcov(es, pair_id=study_id, r=.4, structure="compound")
#' apm_pair_vcov(es, pair_id=study_id, r=.8)
apm_pair_vcov <- function(effects, pair_id, r, structure = c("paired", "compound", "user"), user_V = NULL) {
  dat <- .apm_df(effects); structure <- match.arg(structure)
  if (!"vi" %in% names(dat)) .apm_abort("{.arg effects} must contain {.field vi}.")
  qp <- rlang::enquo(pair_id); pid <- .apm_pull_quo(dat,qp,"pair_id",TRUE); k <- nrow(dat)
  if (structure=="user") {
    if (is.null(user_V)) .apm_abort("{.arg user_V} is required for structure='user'.")
    V <- as.matrix(user_V)
    if (!all(dim(V)==c(k,k))) .apm_abort("{.arg user_V} must have one row and column per effect.")
  } else {
    if (missing(r) || is.null(r)) .apm_abort("{.arg r} is required.")
    if (is.matrix(r)) {
      R <- r; if(!all(dim(R)==c(k,k))) .apm_abort("A correlation matrix supplied as {.arg r} must be k x k.")
    } else {
      if (!is.numeric(r) || any(!is.finite(r)) || any(r <= -1 | r >= 1)) .apm_abort("{.arg r} must lie strictly between -1 and 1.")
      if (length(r)==1L) {
        R <- diag(k)
        blocks <- split(seq_len(k), pid)
        for (ii in blocks) if(length(ii)>1L) R[ii,ii] <- matrix(r,length(ii),length(ii)) + diag(1-r,length(ii))
      } else {
        .apm_abort("For transparent covariance construction, {.arg r} must be a scalar correlation or an explicit correlation matrix in version 0.2.0.")
      }
    }
    sdv <- sqrt(dat$vi); V <- diag(sdv) %*% R %*% diag(sdv)
  }
  if (max(abs(V-t(V)),na.rm=TRUE)>1e-10) .apm_abort("Paired covariance matrix must be symmetric.")
  if (max(abs(diag(V)-dat$vi),na.rm=TRUE)>1e-8) .apm_abort("Paired covariance matrix diagonal must equal {.field vi}.")
  ev <- eigen(V,symmetric=TRUE,only.values=TRUE)$values
  if (min(ev) < -1e-8) .apm_abort("Paired covariance matrix is not positive semidefinite.")
  attr(V,"apm_meta") <- list(pair_id=.apm_name_quo(qp),r=r,structure=structure,min_eigen=min(ev),positive_semidefinite=TRUE,data_hash=.apm_hash_data(dat),backend="native")
  class(V)<-unique(c("apm_vcov",class(V))); V
}
