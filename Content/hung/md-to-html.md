---
date: 2022-03-25 11:55
description: Thay vì ngủ lúc 10h thì mình đã thức đến 1h để làm gì ? 
tags: dev-log, Vietnamese
---
# Làm Blog bằng Publish - Xuất HTML từ file Markdown

<p>Mình viết blog này bằng <a href="https://github.com/JohnSundell/Publish">Publish</a>, nó là một công cụ giúp tạo ra những trang web tĩnh, dành cho những lập trình viên sử dụng Swift. Chi tiết hơn về Publish sẽ được trình bày trong bài viết khác, bài viết này sẽ nói về hành trình mình tìm giải pháp xuất HTML của mình.</p>
<h3>Tại sao phải xuất HTML ?</h3>
<p>Publish vốn có thể tự động parse file Markdown thành HTML, thông qua <a href="https://github.com/JohnSundell/Ink">Ink</a> - một công cụ cũng do tác giả của Publish viết. Tuy nhiên, công cụ này còn rất nhiều thiếu sót (chính tác giả cũng nói vậy), và có rất nhiều tính năng của Markdown không parse được thành HTML (nested block, list in block,... ). Do đó mình bắt đầu đi tìm giải pháp tốt hơn để tạo ra file HTML (vì Publish cũng support raw HTML).</p>
<h3>Typora</h3>
<p>Sau khi tham khảo nhiều Markdown editor thì mình quyết định bắt đầu với <a href="https://typora.io/">Typora</a>, một công cụ được recommend rất nhiều. Typora có rất nhiều ưu điểm, như giao diện tối giản, xuất được rất nhiều định dạng file, đặc biệt có thể xuất HTML without styles - thứ mình rất cần.</p>
<p>Tuy nhiên, vì những nhược điểm sau, mà mình đã không chọn Typora:</p>
<ul>
<li>Tốn phí, $15.</li>
<li>Mình cần side panel để preview, nhưng không có option này.</li>
<li>Kiểu edit WYSIWYG làm mình khó chịu, loay hoay 2 phút cũng không xóa được 1 code block.</li>
</ul>
<h3>Quay đầu là bờ</h3>
<p>Loay hoay thêm 1 lúc với nhiều Markdown editor khác nhưng vẫn không ưng, mình nhớ ra VSCode và quyết định thử với nó. VSCode đã có sẵn rất nhiều thứ mình cần: Vim keybindings, side panel preview, theme/font configurations... . Nhưng có một thứ rất quan trọng mà VSCode đang thiếu: xuất HTML without styles.</p>
<p>Mình có thử google và thấy <a href="https://code.visualstudio.com/docs/languages/markdown#_compiling-markdown-into-html">hướng dẫn</a> của chính VSCode, nhưng có vẻ hơi phức tạp nên mình để lại thử sau. Sau khi thử với nhiều Markdown extension khác nhau, mình vẫn không có được kết quả như ý, vì cùng 1 lí do: những extension này không có option xuất HTML <strong>without styles</strong>. Mình đành quay lại đọc hướng dẫn &quot;chính chủ&quot;.</p>
<h3>markdown-it</h3>
<p>Đọc hướng dẫn của VSCode thì mình thấy họ dùng command <a href="https://github.com/markdown-it/markdown-it">markdown-it</a> để làm ví dụ. Mình có vào xem github thì thấy đây là một thư viện của NodeJs, có kèm theo CLI, và rất dễ sử dụng. Mình mừng như cá gặp nước và nhanh chóng bắt tay vào setup.</p>
<p>Sau vài sự tìm kiếm thì extension mình đã dùng là <a href="https://marketplace.visualstudio.com/items?itemName=edonet.vscode-command-runner">Command Runner</a>, nó cho phép mình bind shortcut key đến một command đã được định nghĩa trước. Đây là đoạn config mình dùng để định nghĩa command, được thêm vào file <code>settings.json</code> của VSCode:</p>
<pre><code class="language-json"> &quot;command-runner.terminal.name&quot;: &quot;runCommand&quot;,
    &quot;command-runner.terminal.autoClear&quot;: true,
    &quot;command-runner.terminal.autoFocus&quot;: true,
    &quot;command-runner.commands&quot;: {
        &quot;Export Markdown to HTML&quot;: &quot;cd ${fileDirname} &amp;&amp; markdown-it ${fileBasename} -o ${fileBasenameNoExtension}.html&quot;,
    },
</code></pre>
<p>Và để bind với shortcut thì mình đã thêm vào <code>keybindings.json</code>:</p>
<pre><code class="language-json">[
    {
        &quot;key&quot;: &quot;ctrl+cmd+e&quot;,
        &quot;command&quot;: &quot;command-runner.run&quot;,
        &quot;args&quot;: {
            &quot;command&quot;: &quot;Export Markdown to HTML&quot;,
            &quot;terminal&quot;: &quot;runCommand&quot;
        }
    }
]
</code></pre>
<p>Như vậy, mỗi lần soạn xong file Markdown, thì mình chỉ cần nhấn Ctrl+Cmd+E thì sẽ có một file HTML cùng tên được xuất ra ở cùng thư mục.</p>
<h3>30 chưa phải là Tết</h3>
<p>Tưởng chừng đã giải quyết được vấn đề và có thể đi ngủ, nhưng đời không như là mơ. Khi test thử với vài sample file thì mình đã phát hiện, <code>markdown-it</code> chưa hỗ trợ một số tính năng của Markdown, như foot-note, subscript, supscript,... . Sau khi quay lại xem document của họ, thì mình mới biết là cần dùng thêm <a href="https://github.com/markdown-it/markdown-it#syntax-extensions">syntax extensions</a> để dùng được những tính năng đó. Tuy nhiên không hề có hướng dẫn nào để load plugin cho CLI, mình tìm rất nhiều nhưng đều không có kết quả. Tới đây thì đã khá tuyệt vọng và buồn ngủ, mình đành tìm file binary của command đó xem source, hi vọng cuối. Để tìm &quot;nguồn gốc&quot; của <code>markdown-it</code>, mình dùng command:</p>
<pre><code class="language-bash">$ type -a markdown-it
</code></pre>
<p>và nhận được output <code>/usr/local/bin/markdown-it</code></p>
<p>Mình tìm đến directory trên và mở file binary lên, thật may là syntax dường như của JS, mình đã có thể load thêm plugin mà mình cần.</p>
<pre><code class="language-javascript">  md = require('..')({
    html: !options.no_html,
    xhtmlOut: false,
    typographer: options.typographer,
    linkify: options.linkify
  }).use(require('markdown-it-footnote'))
    .use(require('markdown-it-sub'))
    .use(require('markdown-it-sup'));
</code></pre>
<p>Voilà! Cuối cùng cũng đi ngủ được rồi.</p>
<h3>Kết</h3>
<p>Mặc dù có thể mình đã mắc phải <a href="https://en.wikipedia.org/wiki/XY_problem">XY Problem</a> khi cố đi tìm cách xuất file HTML, nhưng hành trình đi tìm giải pháp đã giúp mình học thêm và phát hiện được thêm khá nhiều thứ. Worth the effort ^^.</p>
