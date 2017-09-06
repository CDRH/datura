class VraToEs

  ################
  #    XPATHS    #
  ################

  def override_xpaths
    xpaths = {}
    xpaths["date"] = "/vra/work/dateSet[1]/date[1]/earliestDate[1]"
    xpaths["dateDisplay"] = "/vra/work/dateSet[1]/display[1]"
    return xpaths
  end

end
