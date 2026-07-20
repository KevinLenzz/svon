///|
/// Console output wrappers — available only on JS target.

#cfg(target="js")
pub extern "js" fn console_log(msg : String) -> Unit =
  #| (msg) => console.log(msg)

#cfg(target="js")
pub extern "js" fn console_warn(msg : String) -> Unit =
  #| (msg) => console.warn(msg)

#cfg(target="js")
pub extern "js" fn console_error(msg : String) -> Unit =
  #| (msg) => console.error(msg)

#cfg(target="js")
pub extern "js" fn console_info(msg : String) -> Unit =
  #| (msg) => console.info(msg)

#cfg(target="js")
pub extern "js" fn console_debug(msg : String) -> Unit =
  #| (msg) => console.debug(msg)
