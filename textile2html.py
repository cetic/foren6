import argparse
import os
import textile
import re

def links(fulldata):
    links_txt = ''
    for entry in fulldata:
        links_txt += '<li><a href="%s">%s</a></li>\n' % (entry['htmlfile'], entry['options']['LINK_TITLE'])
    return links_txt

def format_pre(text)
    pre_start_indexes = [m.start() for m in re.finditer('<pre>', text)]
    print(pre_start_indexes)

def postprocessing(text)
    text = format_pre(text)
    return text

def generate(template, sourcedir, outdir):
    textile_files = [ f for f in os.listdir(sourcedir) if os.path.isfile(os.path.join(sourcedir,f)) and f.endswith('.textile')]

    page_template = open(template, 'r').read()
    fulldata = []
    for textile_file in textile_files:
        contents = open(os.path.join(sourcedir,textile_file), 'r').read()
        contents_parts = contents.split('===//===//===')
        options_raw = contents_parts[0].split('\n')
        options_dict = {}
        for option in options_raw:
            if '=' in option:
                parts = option.split('=')
                options_dict[parts[0]] = parts[1]
        fulldata_entry = {}
        fulldata_entry['options'] = options_dict
        fulldata_entry['textilefile'] = textile_file
        fulldata_entry['htmlcontent'] = textile.textile(contents_parts[1])
        fulldata_entry['htmlfile'] = os.path.join(outdir,textile_file[:-8]+'.html')
        fulldata.append(fulldata_entry)
    
    links_txt = links(fulldata)
    
    if not os.path.exists(outdir):
        os.makedirs(outdir)
    
    for entry in fulldata:
        htmlfile = open(entry['htmlfile'], 'w')
        htmlcontents = page_template
        htmlcontents = htmlcontents.replace('#TEX2HTML_PAGETITLE', entry['options']['PAGE_TITLE'])
        htmlcontents = htmlcontents.replace('#TEX2HTML_LINKTITLE', entry['options']['LINK_TITLE'])
        htmlcontents = htmlcontents.replace('#TEX2HTML_LINKS', links_txt)
        htmlcontents = htmlcontents.replace('#TEX2HTML_BODY', entry['htmlcontent'])
        htmlfile.write(htmlcontents)
        htmlfile.close()

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-t', '--template', default='template.html')
    parser.add_argument('-s', '--sourcedir', default='pages-textile')
    parser.add_argument('-o', '--outputdir', default='pages-html')
    args = parser.parse_args()
    generate(args.template, args.sourcedir, args.outputdir)


