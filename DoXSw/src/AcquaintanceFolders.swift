//
//  AcquaintanceFolders.swift
//  DoXLogic
//
//  Created by Nick Utenkov on 07/01/17.
//  Copyright © 2017 Nick Utenkov. All rights reserved.
//

import Foundation
import UIKit
import CoreData

final class FolderInfo
{
	var folderId = 0
	var folderName = ""
	var folderParentId = 0
	var level = 0
	var docsUnread = 0
	var docsAll = 0
	var image:UIImage? = nil
	var name:String! = ""
}

final class AcquaintanceFolders : NSObject
{
	@IBOutlet var tableView:UITableView!
	var m_currentFolderId = 0
	private var m_imgFolderOpened:UIImage!
	private var m_imgFolderClosed:UIImage!
	var m_arFolders:[FolderInfo] = []
	let RowH:CGFloat = 40
	var initialRow = -1
	var bDeselected = false
	var m_imgWith:CGFloat = 0
	var idxSelected = -1

	var m_moc:NSManagedObjectContext?

	override func awakeFromNib()
	{
		super.awakeFromNib()
		m_imgFolderOpened = UIImage(named:"FolderOpened32")
		m_imgFolderClosed = UIImage(named:"FolderClosed32")
		m_imgWith = m_imgFolderOpened.size.width
	}

	func createFoldersList()
	{
		m_arFolders.removeAll()

		let pFolderInfo = FolderInfo()
		pFolderInfo.folderId = -1//special value
		pFolderInfo.folderName = "AllFolders".localized
		pFolderInfo.folderParentId = -1//special value
		m_arFolders.append(pFolderInfo)

		let req:NSFetchRequest<FolderMO> = FolderMO.fetchRequest()
		if let arFolders = try? m_moc!.fetch(req)
		{
			var tmpArray:[FolderInfo] = []
			for pFolder in arFolders
			{
				let pFolderInfo = FolderInfo()
				pFolderInfo.folderId = pFolder.folderId
				pFolderInfo.folderName = pFolder.folderName!
				pFolderInfo.folderParentId = pFolder.folderParentId
				tmpArray.append(pFolderInfo)
			}
			traverseNodes(0,tmpArray,-1)
		}
		NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kDocFolderListChanged),object:m_arFolders.count)
		refreshFolders()
	}

	func refreshFolders()
	{
		for i in 0..<m_arFolders.count {setCellDataForIndex(i)}
		bDeselected = false
		self.tableView.reloadData()
	}

	func traverseNodes(_ root:Int,_ ar:[FolderInfo],_ level:Int)
	{
		let curLevel = level+1
		for pFolderInfo in ar
		{
			if pFolderInfo.folderParentId == root
			{
				pFolderInfo.level = curLevel
				m_arFolders.append(pFolderInfo)
				traverseNodes(pFolderInfo.folderId,ar,curLevel)
			}
		}
	}

	func getFolderIdsArray() -> [Int]
	{////skips first element ('All folders')
		var arOut:[Int] = []
		for i in 1..<m_arFolders.count {arOut.append(m_arFolders[i].folderId)}
		return arOut
	}

	func setCellDataForIndex(_ idx:Int)
	{
		let pFolderInfo = m_arFolders[idx]

		if idx == 0 {pFolderInfo.image = UIImage(named:"AllFolders32.png")!}
		else {pFolderInfo.image = pFolderInfo.docsAll > 0 ? m_imgFolderOpened : m_imgFolderClosed}
		
		if pFolderInfo.docsUnread > 0
		{
			pFolderInfo.name = String(format:"%@ (%d)",pFolderInfo.folderName,pFolderInfo.docsUnread)
		}
		else
		{
			pFolderInfo.name = pFolderInfo.folderName
		}
	}

	func selectFolder(_ folderId:Int)
	{
		if m_arFolders.count > 0
		{
			var idxPath = IndexPath(row:0,section:0)//select all docs folder if folder to select is invalid
			for i in 0..<m_arFolders.count
			{
				let pFolderInfo = m_arFolders[i]
				if pFolderInfo.folderId == folderId
				{
					idxPath = IndexPath(row:i,section:0)
					break
				}
			}
			self.tableView(self.tableView!,didSelectRowAt:idxPath)
			self.tableView.selectRow(at:idxPath,animated:false,scrollPosition:.middle)
			initialRow = idxPath.row
		}
	}

	func getRowH() -> CGFloat
	{
		return RowH
	}
}

extension AcquaintanceFolders : UITableViewDataSource
{
	func tableView(_ tableView: UITableView,numberOfRowsInSection: Int) -> Int
	{
		return m_arFolders.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt: IndexPath) -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCell(withIdentifier:"AFC") as! AcquFolderCell
		let cellData = m_arFolders[cellForRowAt.row]
		cell.folderImage.image = cellData.image
		cell.folderName.text = cellData.name
		cell.constraintImageOffset.constant = CGFloat(cellData.level)*m_imgWith
		return cell
	}

	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
	{//gradient should be here(in case not updated cell width at first table display)
		if idxSelected != indexPath.row {cell.contentView.removeGradientLayer()}
		else {cell.contentView.makeGradient(true,ClrDef.clrGrad1Blue.cgColor,ClrDef.clrGrad2Blue.cgColor)}
	}
}

extension AcquaintanceFolders : UITableViewDelegate
{
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		return RowH
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath)
	{
		if !bDeselected && initialRow != -1
		{
			self.tableView(tableView,didDeselectRowAt:IndexPath(row:initialRow,section:0))
		}
		idxSelected = didSelectRowAt.row
		let pFolderInfo = m_arFolders[idxSelected]
		let cell = tableView.cellForRow(at: didSelectRowAt)
		cell?.contentView.makeGradient(true,ClrDef.clrGrad1Blue.cgColor,ClrDef.clrGrad2Blue.cgColor)
		m_currentFolderId = pFolderInfo.folderId
		NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kDocFolderSelected),object:pFolderInfo)
	}

	func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
	{
		bDeselected = true
		let cell = tableView.cellForRow(at: indexPath)
		cell?.contentView.backgroundColor = UIColor.clear
		cell?.contentView.removeGradientLayer()
	}
}
