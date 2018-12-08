package io.github.ponnamkarthik.nativeweb;

import io.flutter.plugin.common.PluginRegistry.Registrar;

/** NativewebPlugin */
public class NativewebPlugin {

  /** Registering viewfactory */
  public static void registerWith(Registrar registrar) {
    registrar
            .platformViewRegistry()
            .registerViewFactory(
                    "nativeweb", new WebFactory(registrar));
  }
}
