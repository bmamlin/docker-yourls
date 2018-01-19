<?php
/*
Plugin Name: Merge query string
Plugin URI: https://fs.fnkr.net/f7d0bb6630134aa19394
Description: Merge query string of request and target URL.
Version: 2.1
Author: fnkr
Author URI: https://www.fnkr.net
License: Creative Commons Attribution 3.0 Unported: https://creativecommons.org/licenses/by/3.0/
*/

yourls_add_action( 'redirect_shorturl', 'fnkr_merge_query_string' );

function fnkr_merge_query_string($url) {
    $parsed_url = parse_url($url[0]);

    parse_str($_SERVER['QUERY_STRING'], $query);
    parse_str($parsed_url['query'], $url_query);

    $a = array_merge($query, $url_query);
    $parsed_url['query'] = http_build_query($a);

    $new_url = $parsed_url['scheme'].'://'.$parsed_url['host'];
    if (isset($parsed_url['port']) && $parsed_url['port'] != '')
       $new_url = $new_url.':'.$parsed_url['port'];
    $new_url = $new_url.$parsed_url['path'];


    if (isset($parsed_url['query']) && $parsed_url['query'] != '')
        $new_url = $new_url.'?'.$parsed_url['query'];

    global $url;
    $url = $new_url;
}