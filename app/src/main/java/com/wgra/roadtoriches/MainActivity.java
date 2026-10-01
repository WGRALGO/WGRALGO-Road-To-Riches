package com.wgra.roadtoriches;

import android.app.Activity;
import android.app.AlertDialog;
import android.os.Bundle;
import android.view.View;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

/**
 * WGRALGO Road to Riches: Lease It or Own It or Hoof It.
 *
 * A single full-screen WebView that loads the bundled offline game from
 * assets/www/index.html. No networking, no third-party SDKs. The WebView is
 * locked down: JavaScript is enabled (the game needs it) but file access,
 * content access and external navigation are all disabled.
 */
public class MainActivity extends Activity {

    private WebView webView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        webView = new WebView(this);
        setContentView(webView);

        WebView.setWebContentsDebuggingEnabled(false);

        WebSettings s = webView.getSettings();
        s.setJavaScriptEnabled(true);   // game requires JS
        s.setDomStorageEnabled(false);  // nothing is saved on the device
        s.setAllowFileAccess(false);
        s.setAllowContentAccess(false);
        s.setAllowFileAccessFromFileURLs(false);
        s.setAllowUniversalAccessFromFileURLs(false);
        s.setMediaPlaybackRequiresUserGesture(true);
        s.setMixedContentMode(WebSettings.MIXED_CONTENT_NEVER_ALLOW);
        s.setTextZoom(100);             // layout is designed for 100%
        webView.setBackgroundColor(0xFF000000);
        webView.setOverScrollMode(View.OVER_SCROLL_NEVER);

        // Keep all navigation inside the bundled assets — block everything else.
        webView.setWebViewClient(new WebViewClient() {
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest req) {
                String url = req.getUrl().toString();
                return !url.startsWith("file:///android_asset/");
            }
        });

        webView.loadUrl("file:///android_asset/www/index.html");
    }

    /**
     * Hardware back button:
     *  - first asks the web app to handle it (close a definition, a menu sheet,
     *    or go back to the setup screen);
     *  - if the web app is already on the setup screen, confirm before exit.
     */
    @Override
    public void onBackPressed() {
        webView.evaluateJavascript(
                "(window.onAndroidBack && window.onAndroidBack())",
                value -> {
                    if ("true".equals(value)) {
                        return; // handled inside the app
                    }
                    new AlertDialog.Builder(MainActivity.this)
                            .setTitle("Exit Road to Riches?")
                            .setMessage("Leave Road to Riches: Lease It or Own It or Hoof It?")
                            .setPositiveButton("Exit", (d, w) -> finish())
                            .setNegativeButton("Stay", null)
                            .show();
                });
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (webView != null) webView.onPause();
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (webView != null) webView.onResume();
    }

    @Override
    protected void onDestroy() {
        if (webView != null) {
            webView.loadUrl("about:blank");
            webView.destroy();
            webView = null;
        }
        super.onDestroy();
    }
}
