require "fileutils"
require "erb"

# Represents a code template
class Template
  # templateFile - the name of the code template file to process
  # outputFile - an ERB template specifying the name to be given to output files that are generated by this template
  # overwrite - specify true to overwrite the file if it exists, or false not to
  def initialize(codeTemplateFile, outFilenameTemplate, overwrite)
    @codeTemplateFile = codeTemplateFile
    @outFilenameTemplate = outFilenameTemplate
    @overwrite = overwrite
  end
  
  # runs this template using the specified ElementDef as the binding context for the template
  # elementDef - the model element that the template operates on
  # templateDir - the name of the directory where the template files are located
  # destDir - the root directory where output files will be placed
  def run(elementDef, templateDir, destDir)
    #use the namespace of the model to extend the destDir
    #e.g. if destDir = . and the namespace is Foo.Bar, destDir becomes ./Foo/Bar
    #HACK: the ClearCanvas portion of the namespace is removed first
    destDir = File.expand_path(elementDef.namespace.gsub("ClearCanvas.", "").gsub('.', "/"), destDir)
    
    # create the erb once only, since it can be re-used
    @outFilenameERB = ERB.new(@outFilenameTemplate) if @outFilenameERB == nil
    
    # generate the output path, including the output file name
    outputPath = File.expand_path(@outFilenameERB.result(elementDef.get_binding), destDir)

    # abort if the file exists already and should not be overwritten
    return if(!@overwrite && File.exist?(outputPath))
    
    # create the erb once only, since it can be re-used
    @codeERB = ERB.new(IO.read(File.expand_path(@codeTemplateFile, templateDir)), nil, "") if @codeERB == nil
  
    #create output folder if doesn't exist
    FileUtils.mkdir_p(File.split(outputPath)[0])

    #write the ERB output to a file
    File.open(outputPath, "w") do |outStream|
      outStream.print(@codeERB.result(elementDef.get_binding))
    end
    outputPath  #return the name of the generated file
  end
end