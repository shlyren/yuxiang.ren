{# Social Links #}
{% include "./_footer/social.swig" %}

<div class="copyright">
  <span class="copyright-year">
    {% set current = date(Date.now(), "YYYY") %}
    &copy; 
    {% if theme.since and theme.since != current %} 
      {{ theme.since }} - 
    {% endif %}
    {{ current }}
    <a class='theme-link' href='mailto:{{ theme.social.email }}', target='_blank'>{{ config.author }}</a>
    | 在Github上查看网站
    <a class="theme-link" href='{{ theme.link.sourceCode }}', target='_blank'>源码</a>。
     <script type="text/javascript" src="https://s95.cnzz.com/z_stat.php?id=1259844339&web_id=1259844339"></script> 
  </span>

  <span class="theme-info">
    <a href="{{ theme.link.icp }}" target="_blank" style="display:inline-block;height:20px;line-height:20px;">
    <p class="theme-link" style="float:left;margin: 0px 0px 0px 5px"> 浙ICP备17016497号-1</p>
    </a>
    <a style="display:inline-block;line-height:20px;"> | </a>
    <a href="{{ theme.link.beian }}" target="_blank" style="display:inline-block;line-height:20px;">
    <img src="{{ theme.link.beianIcon }}" style="float:left;">
    <p class="theme-link" style="float:left;margin: 0px 0px 0px 5px;">浙公网安备 33010602008160号</p>
  </a>
  </span>

  
</div>
